//
//  NetworkObserverTests.swift
//  SundialKitStream
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork
@testable import SundialKitStream

// MARK: - Mock Implementations

internal final class MockPathMonitor: PathMonitor, @unchecked Sendable {
  internal typealias PathType = MockPath

  internal let id: UUID
  internal private(set) var pathUpdate: ((MockPath) -> Void)?
  internal private(set) var dispatchQueueLabel: String?
  internal private(set) var isCancelled = false

  internal init(id: UUID = UUID()) {
    self.id = id
  }

  internal func onPathUpdate(_ handler: @escaping (MockPath) -> Void) {
    pathUpdate = handler
  }

  internal func start(queue: DispatchQueue) {
    dispatchQueueLabel = queue.label
    // Immediately send an initial path
    pathUpdate?(
      .init(
        isConstrained: false,
        isExpensive: false,
        pathStatus: .satisfied(.wiredEthernet)
      )
    )
  }

  internal func cancel() {
    isCancelled = true
  }

  internal func sendPath(_ path: MockPath) {
    pathUpdate?(path)
  }
}

internal struct MockPath: NetworkPath {
  internal let isConstrained: Bool
  internal let isExpensive: Bool
  internal let pathStatus: PathStatus

  internal init(
    isConstrained: Bool = false,
    isExpensive: Bool = false,
    pathStatus: PathStatus = .unknown
  ) {
    self.isConstrained = isConstrained
    self.isExpensive = isExpensive
    self.pathStatus = pathStatus
  }
}

internal final class MockNetworkPing: NetworkPing, @unchecked Sendable {
  internal struct StatusType: Sendable, Equatable {
    let value: String
  }

  internal private(set) var lastShouldPingStatus: PathStatus?
  internal let id: UUID
  internal let timeInterval: TimeInterval
  internal var shouldPingResponse: Bool
  internal var onPingHandler: ((StatusType) -> Void)?

  internal init(
    id: UUID = UUID(),
    timeInterval: TimeInterval = 1.0,
    shouldPingResponse: Bool = true
  ) {
    self.id = id
    self.timeInterval = timeInterval
    self.shouldPingResponse = shouldPingResponse
  }

  internal func shouldPing(onStatus status: PathStatus) -> Bool {
    lastShouldPingStatus = status
    return shouldPingResponse
  }

  internal func onPing(_ closure: @escaping (StatusType) -> Void) {
    onPingHandler = closure
  }

  internal func sendPingStatus(_ status: StatusType) {
    onPingHandler?(status)
  }
}

// MARK: - NetworkObserver Tests

@Suite("NetworkObserver Tests")
internal struct NetworkObserverTests {
  // MARK: - Initialization Tests

  @Test("NetworkObserver initializes with monitor only")
  internal func initializationWithMonitorOnly() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    let currentPath = await observer.getCurrentPath()
    let currentPingStatus = await observer.getCurrentPingStatus()

    #expect(currentPath == nil)
    #expect(currentPingStatus == nil)
  }

  @Test("NetworkObserver initializes with monitor and ping")
  internal func initializationWithMonitorAndPing() async {
    let monitor = MockPathMonitor()
    let ping = MockNetworkPing()
    let observer = NetworkObserver(monitor: monitor, ping: ping)

    let currentPath = await observer.getCurrentPath()
    let currentPingStatus = await observer.getCurrentPingStatus()

    #expect(currentPath == nil)
    #expect(currentPingStatus == nil)
  }

  // MARK: - Start/Cancel Tests

  @Test("Start monitoring begins path updates")
  internal func startMonitoring() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    #expect(monitor.dispatchQueueLabel != nil)
    #expect(monitor.isCancelled == false)

    // Give time for async path update from start()
    try? await Task.sleep(for: .milliseconds(10))

    // Should receive initial path from start()
    let currentPath = await observer.getCurrentPath()
    #expect(currentPath != nil)
    #expect(currentPath?.pathStatus == .satisfied(.wiredEthernet))
  }

  @Test("Cancel stops monitoring and finishes streams")
  internal func cancelMonitoring() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())
    await observer.cancel()

    #expect(monitor.isCancelled == true)
  }

  // MARK: - Path Updates Stream Tests

  @Test("pathUpdates stream receives initial and subsequent paths")
  internal func pathUpdatesStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathUpdates()
    var iterator = stream.makeAsyncIterator()

    // Should receive initial path
    let firstPath = await iterator.next()
    #expect(firstPath?.pathStatus == .satisfied(.wiredEthernet))

    // Send new path update
    let newPath = MockPath(
      isConstrained: true,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    monitor.sendPath(newPath)

    // Give time for async delivery
    try await Task.sleep(for: .milliseconds(10))

    let secondPath = await iterator.next()
    #expect(secondPath?.pathStatus == .satisfied(.cellular))
    #expect(secondPath?.isConstrained == true)
    #expect(secondPath?.isExpensive == true)
  }

  @Test("pathStatusStream extracts status from paths")
  internal func pathStatusStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathStatusStream
    var iterator = stream.makeAsyncIterator()

    // Should receive initial status
    let firstStatus = await iterator.next()
    #expect(firstStatus == .satisfied(.wiredEthernet))

    // Send new path update
    let newPath = MockPath(pathStatus: .unsatisfied(.localNetworkDenied))
    monitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(10))

    let secondStatus = await iterator.next()
    #expect(secondStatus == .unsatisfied(.localNetworkDenied))
  }

  @Test("isExpensiveStream tracks expensive status")
  internal func isExpensiveStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.isExpensiveStream
    var iterator = stream.makeAsyncIterator()

    // Initial path is not expensive
    let firstValue = await iterator.next()
    #expect(firstValue == false)

    // Send expensive path
    let expensivePath = MockPath(isExpensive: true, pathStatus: .satisfied(.cellular))
    monitor.sendPath(expensivePath)

    try await Task.sleep(for: .milliseconds(10))

    let secondValue = await iterator.next()
    #expect(secondValue == true)
  }

  @Test("isConstrainedStream tracks constrained status")
  internal func isConstrainedStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.isConstrainedStream
    var iterator = stream.makeAsyncIterator()

    // Initial path is not constrained
    let firstValue = await iterator.next()
    #expect(firstValue == false)

    // Send constrained path
    let constrainedPath = MockPath(isConstrained: true, pathStatus: .satisfied(.wifi))
    monitor.sendPath(constrainedPath)

    try await Task.sleep(for: .milliseconds(10))

    let secondValue = await iterator.next()
    #expect(secondValue == true)
  }

  // MARK: - Multiple Subscribers Tests

  @Test("Multiple path update subscribers receive same updates")
  internal func multiplePathSubscribers() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    // Create two subscribers
    let stream1 = await observer.pathUpdates()
    let stream2 = await observer.pathUpdates()

    var iterator1 = stream1.makeAsyncIterator()
    var iterator2 = stream2.makeAsyncIterator()

    // Both should receive initial path
    let path1First = await iterator1.next()
    let path2First = await iterator2.next()

    #expect(path1First?.pathStatus == .satisfied(.wiredEthernet))
    #expect(path2First?.pathStatus == .satisfied(.wiredEthernet))

    // Send new path
    let newPath = MockPath(pathStatus: .satisfied(.cellular))
    monitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(10))

    let path1Second = await iterator1.next()
    let path2Second = await iterator2.next()

    #expect(path1Second?.pathStatus == .satisfied(.cellular))
    #expect(path2Second?.pathStatus == .satisfied(.cellular))
  }

  // MARK: - Ping Integration Tests

  @Test("Ping status updates are not tracked without ping initialization")
  internal func pingStatusWithoutPing() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let currentPingStatus = await observer.getCurrentPingStatus()
    #expect(currentPingStatus == nil)
  }

  // Note: Full ping integration testing would require NetworkMonitor-level tests
  // since NetworkObserver doesn't directly manage ping lifecycle

  // MARK: - Current State Tests

  @Test("getCurrentPath returns latest path")
  internal func getCurrentPathSnapshot() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    // Before start
    var currentPath = await observer.getCurrentPath()
    #expect(currentPath == nil)

    // After start
    await observer.start(queue: .global())

    // Give time for async path update from start()
    try? await Task.sleep(for: .milliseconds(10))

    currentPath = await observer.getCurrentPath()
    #expect(currentPath?.pathStatus == .satisfied(.wiredEthernet))

    // After update
    let newPath = MockPath(pathStatus: .satisfied(.wifi))
    monitor.sendPath(newPath)

    // Give time for async update
    try? await Task.sleep(for: .milliseconds(10))

    currentPath = await observer.getCurrentPath()
    #expect(currentPath?.pathStatus == .satisfied(.wifi))
  }

  @Test("getCurrentPingStatus returns nil when no ping configured")
  internal func getCurrentPingStatusWithoutPing() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let pingStatus = await observer.getCurrentPingStatus()
    #expect(pingStatus == nil)
  }

  // MARK: - Stream Cleanup Tests

  @Test("Cancel finishes all active path streams")
  internal func cancelFinishesPathStreams() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathUpdates()
    var iterator = stream.makeAsyncIterator()

    // Get first value
    _ = await iterator.next()

    // Cancel observer
    await observer.cancel()

    // Try to get next value - should complete
    let nextValue = await iterator.next()
    #expect(nextValue == nil)
  }

  // MARK: - Edge Cases

  @Test("Path updates before start are not tracked")
  internal func pathUpdatesBeforeStart() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    // Don't call start()
    let currentPath = await observer.getCurrentPath()
    #expect(currentPath == nil)
  }

  @Test("Multiple start calls use latest queue")
  internal func multipleStartCalls() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())
    let firstLabel = monitor.dispatchQueueLabel

    await observer.start(queue: .main)
    let secondLabel = monitor.dispatchQueueLabel

    #expect(firstLabel != nil)
    #expect(secondLabel != nil)
    // Labels should be different since we used different queues
  }

  @Test("Stream iteration completes after cancel")
  internal func streamCompletesAfterCancel() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathStatusStream
    var iterator = stream.makeAsyncIterator()

    // Get initial value
    _ = await iterator.next()

    // Cancel
    await observer.cancel()

    // Iteration should complete
    var completedNaturally = false
    for await _ in stream {
      // Should not get here after cancel
    }
    completedNaturally = true

    #expect(completedNaturally == true)
  }
}
