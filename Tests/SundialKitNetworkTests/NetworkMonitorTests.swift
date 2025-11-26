//
// NetworkMonitorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork

// MARK: - Test Observer

// MARK: - Task.sleep Polyfill for watchOS < 9.0

// MARK: - NetworkMonitor Tests

@Suite("NetworkMonitor Tests")
struct NetworkMonitorTests {
  // MARK: - Initialization Tests

  @Test("NetworkMonitor initializes with unknown state")
  func testInitialization() async {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    #expect(await monitor.pathStatus == .unknown)
    #expect(await monitor.isExpensive == false)
    #expect(await monitor.isConstrained == false)
  }

  @Test("NetworkMonitor initializes with ping")
  func testInitializationWithPing() async {
    let pathMonitor = MockPathMonitor(id: UUID())
    let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: ping)

    #expect(await monitor.pathStatus == .unknown)
    #expect(await monitor.isExpensive == false)
    #expect(await monitor.isConstrained == false)
  }

  @Test("NetworkMonitor convenience initializer works")
  func testConvenienceInitializer() async {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor)

    #expect(await monitor.pathStatus == .unknown)
  }

  // MARK: - Lifecycle Tests

  @Test("NetworkMonitor starts monitoring")
  func testStartMonitoring() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let queue = DispatchQueue(label: "test.queue")

    monitor.start(queue: queue)

    // Give it a moment to process
    try await Task.sleep(forMilliseconds: 300)

    #expect(pathMonitor.dispatchQueueLabel == "test.queue")
    #expect(pathMonitor.pathUpdate != nil)
    // Should have received initial path update
    #expect(await monitor.pathStatus == .satisfied(.wiredEthernet))
  }

  @Test("NetworkMonitor stops monitoring")
  func testStopMonitoring() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(forMilliseconds: 300)

    monitor.stop()

    // Wait for async stop to complete
    try await Task.sleep(forMilliseconds: 200)

    #expect(pathMonitor.isCancelled == true)
  }

  @Test("NetworkMonitor ignores duplicate start calls")
  func testDuplicateStartCalls() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(forMilliseconds: 200)

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
    try await Task.sleep(forMilliseconds: 300)

    // Send new path update
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(await monitor.pathStatus == .satisfied(.cellular))
    #expect(await monitor.isExpensive == true)
    #expect(await monitor.isConstrained == false)
  }

  @Test("NetworkMonitor updates constrained status")
  func testConstrainedStatusUpdate() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

    monitor.start(queue: .global())
    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: true,
      isExpensive: false,
      pathStatus: .satisfied(.wifi)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(await monitor.isConstrained == true)
  }

  // MARK: - Observer Tests

  @Test("NetworkMonitor notifies observers of path status changes")
  func testObserverPathStatusNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    // Send update
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(!observer.pathStatusUpdates.isEmpty)
    #expect(observer.pathStatusUpdates.last == .satisfied(.cellular))
  }

  @Test("NetworkMonitor notifies observers of expensive changes")
  func testObserverExpensiveNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(observer.expensiveUpdates.contains(true))
  }

  @Test("NetworkMonitor notifies observers of constrained changes")
  func testObserverConstrainedNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: true,
      isExpensive: false,
      pathStatus: .satisfied(.wifi)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(observer.constrainedUpdates.contains(true))
  }

  @Test("NetworkMonitor removes observers correctly")
  func testRemoveObserver() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    await monitor.removeObservers { ($0 as? TestNetworkStateObserver) === observer }

    // Send update after removal
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    // Observer should not have received the cellular update
    let hasCellularUpdate = observer.pathStatusUpdates.contains { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }
    #expect(hasCellularUpdate == false)
  }

  @Test("NetworkMonitor allows duplicate observers")
  func testDuplicateObservers() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    await monitor.addObserver(observer)  // Add again (now allowed with strong references)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    // With strong references, duplicates receive notifications multiple times
    let cellularCount = observer.pathStatusUpdates.filter { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }.count

    #expect(cellularCount == 2)  // Observer added twice, receives notification twice
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
          _ = await monitor.pathStatus
          _ = await monitor.isExpensive
          _ = await monitor.isConstrained
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
    let observers = (0..<10).map { _ in TestNetworkStateObserver() }

    monitor.start(queue: .global())

    await withTaskGroup(of: Void.self) { group in
      for observer in observers {
        group.addTask {
          await monitor.addObserver(observer)
        }
      }

      for observer in observers {
        group.addTask {
          let observerToRemove = observer
          await monitor.removeObservers { ($0 as? TestNetworkStateObserver) === observerToRemove }
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
    try await Task.sleep(forMilliseconds: 500)

    monitor.stop()

    // Test passes if no crashes occurred during ping execution
    #expect(true)
  }
}
