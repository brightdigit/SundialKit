//
// NetworkMonitorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork

// MARK: - NetworkMonitor Tests

@Suite("NetworkMonitor Tests", .disabled(if: isWasm))
struct NetworkMonitorTests {
  // MARK: - Initialization Tests

  @Test("NetworkMonitor initializes with unknown state")
  func testInitialization() async {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

      #expect(await monitor.pathStatus == .unknown)
      #expect(await monitor.isExpensive == false)
      #expect(await monitor.isConstrained == false)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor initializes with ping")
  func testInitializationWithPing() async {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: ping)

      #expect(await monitor.pathStatus == .unknown)
      #expect(await monitor.isExpensive == false)
      #expect(await monitor.isConstrained == false)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor convenience initializer works")
  func testConvenienceInitializer() async {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let monitor = NetworkMonitor(monitor: pathMonitor)

      #expect(await monitor.pathStatus == .unknown)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  // MARK: - Lifecycle Tests

  @Test("NetworkMonitor starts monitoring")
  func testStartMonitoring() async throws {
    #if canImport(Dispatch)
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
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor stops monitoring")
  func testStopMonitoring() async throws {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

      monitor.start(queue: .global())
      try await Task.sleep(forMilliseconds: 300)

      monitor.stop()

      // Wait for async stop to complete
      try await Task.sleep(forMilliseconds: 200)

      #expect(pathMonitor.isCancelled == true)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor ignores duplicate start calls")
  func testDuplicateStartCalls() async throws {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

      monitor.start(queue: .global())
      try await Task.sleep(forMilliseconds: 200)

      // Second start should be ignored
      monitor.start(queue: .global())

      #expect(pathMonitor.dispatchQueueLabel != nil)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor ignores duplicate stop calls")
  func testDuplicateStopCalls() {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)

      // Stop without starting should be safe
      monitor.stop()
      monitor.stop()

      #expect(pathMonitor.isCancelled == false)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  // MARK: - Path Update Tests

  @Test("NetworkMonitor updates path status")
  func testPathStatusUpdate() async throws {
    #if canImport(Dispatch)
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
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }
}
