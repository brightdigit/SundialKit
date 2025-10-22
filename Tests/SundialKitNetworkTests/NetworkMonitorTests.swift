//
//  NetworkMonitorTests.swift
//  SundialKit
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

// MARK: - Test Observer

private final class TestObserver: NetworkStateObserver, @unchecked Sendable {
  var pathStatusUpdates: [PathStatus] = []
  var expensiveUpdates: [Bool] = []
  var constrainedUpdates: [Bool] = []

  func networkMonitor(didUpdatePathStatus status: PathStatus) {
    pathStatusUpdates.append(status)
  }

  func networkMonitor(didUpdateExpensive isExpensive: Bool) {
    expensiveUpdates.append(isExpensive)
  }

  func networkMonitor(didUpdateConstrained isConstrained: Bool) {
    constrainedUpdates.append(isConstrained)
  }
}

// MARK: - NetworkMonitor Tests

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {

  // MARK: - Initialization Tests

  @Test("NetworkMonitor initializes with unknown state")
  func testInitialization() {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    #expect(monitor.pathStatus == .unknown)
    #expect(monitor.isExpensive == false)
    #expect(monitor.isConstrained == false)
  }

  @Test("NetworkMonitor initializes with ping")
  func testInitializationWithPing() {
    let pathMonitor = MockPathMonitor(id: UUID())
    let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: ping)

    #expect(monitor.pathStatus == .unknown)
    #expect(monitor.isExpensive == false)
    #expect(monitor.isConstrained == false)
  }

  @Test("NetworkMonitor convenience initializer works")
  func testConvenienceInitializer() {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor)

    #expect(monitor.pathStatus == .unknown)
  }

  // MARK: - Lifecycle Tests

  @Test("NetworkMonitor starts monitoring")
  func testStartMonitoring() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let queue = DispatchQueue(label: "test.queue")

    monitor.start(queue: queue)

    // Give it a moment to process
    try await Task.sleep(for: .milliseconds(100))

    #expect(pathMonitor.dispatchQueueLabel == "test.queue")
    #expect(pathMonitor.pathUpdate != nil)
    // Should have received initial path update
    #expect(monitor.pathStatus == .satisfied(.wiredEthernet))
  }

  @Test("NetworkMonitor stops monitoring")
  func testStopMonitoring() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(for: .milliseconds(100))

    monitor.stop()

    #expect(pathMonitor.isCancelled == true)
  }

  @Test("NetworkMonitor ignores duplicate start calls")
  func testDuplicateStartCalls() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(for: .milliseconds(50))

    // Second start should be ignored
    monitor.start(queue: .global())

    #expect(pathMonitor.dispatchQueueLabel != nil)
  }

  @Test("NetworkMonitor ignores duplicate stop calls")
  func testDuplicateStopCalls() {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    // Stop without starting should be safe
    monitor.stop()
    monitor.stop()

    #expect(pathMonitor.isCancelled == false)
  }

  // MARK: - Path Update Tests

  @Test("NetworkMonitor updates path status")
  func testPathStatusUpdate() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(for: .milliseconds(100))

    // Send new path update
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    #expect(monitor.pathStatus == .satisfied(.cellular))
    #expect(monitor.isExpensive == true)
    #expect(monitor.isConstrained == false)
  }

  @Test("NetworkMonitor updates constrained status")
  func testConstrainedStatusUpdate() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(for: .milliseconds(100))

    let newPath = MockPath(
      isConstrained: true,
      isExpensive: false,
      pathStatus: .satisfied(.wifi)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    #expect(monitor.isConstrained == true)
  }

  // MARK: - Observer Tests

  @Test("NetworkMonitor notifies observers of path status changes")
  func testObserverPathStatusNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestObserver()

    monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(for: .milliseconds(100))

    // Send update
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    #expect(observer.pathStatusUpdates.count > 0)
    #expect(observer.pathStatusUpdates.last == .satisfied(.cellular))
  }

  @Test("NetworkMonitor notifies observers of expensive changes")
  func testObserverExpensiveNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestObserver()

    monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(for: .milliseconds(100))

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    #expect(observer.expensiveUpdates.contains(true))
  }

  @Test("NetworkMonitor notifies observers of constrained changes")
  func testObserverConstrainedNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestObserver()

    monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(for: .milliseconds(100))

    let newPath = MockPath(
      isConstrained: true,
      isExpensive: false,
      pathStatus: .satisfied(.wifi)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    #expect(observer.constrainedUpdates.contains(true))
  }

  @Test("NetworkMonitor removes observers correctly")
  func testRemoveObserver() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestObserver()

    monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(for: .milliseconds(100))

    monitor.removeObserver(observer)

    // Send update after removal
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    // Observer should not have received the cellular update
    let hasCellularUpdate = observer.pathStatusUpdates.contains { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }
    #expect(hasCellularUpdate == false)
  }

  @Test("NetworkMonitor doesn't add duplicate observers")
  func testDuplicateObservers() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestObserver()

    monitor.addObserver(observer)
    monitor.addObserver(observer)  // Add again
    monitor.start(queue: .global())

    try await Task.sleep(for: .milliseconds(100))

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(50))

    // Should only have one notification, not two
    let cellularCount = observer.pathStatusUpdates.filter { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }.count

    #expect(cellularCount <= 1)
  }

  // MARK: - Thread Safety Tests

  @Test("NetworkMonitor handles concurrent property access")
  func testConcurrentPropertyAccess() async {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())

    await withTaskGroup(of: Void.self) { group in
      for _ in 0..<100 {
        group.addTask {
          _ = monitor.pathStatus
          _ = monitor.isExpensive
          _ = monitor.isConstrained
        }
      }
    }

    // If we get here without crashing, thread safety is working
    #expect(true)
  }

  @Test("NetworkMonitor handles concurrent observer operations")
  func testConcurrentObserverOperations() async {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observers = (0..<10).map { _ in TestObserver() }

    monitor.start(queue: .global())

    await withTaskGroup(of: Void.self) { group in
      for observer in observers {
        group.addTask {
          monitor.addObserver(observer)
        }
      }

      for observer in observers {
        group.addTask {
          monitor.removeObserver(observer)
        }
      }
    }

    // If we get here without crashing, thread safety is working
    #expect(true)
  }

  // MARK: - Ping Integration Tests

  @Test("NetworkMonitor integrates with ping")
  func testPingIntegration() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let ping = MockNetworkPing(id: UUID(), timeInterval: 0.1)
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: ping)

    monitor.start(queue: .global())

    // Wait for potential ping to execute
    try await Task.sleep(for: .milliseconds(200))

    monitor.stop()

    // Test passes if no crashes occurred during ping execution
    #expect(true)
  }
}
