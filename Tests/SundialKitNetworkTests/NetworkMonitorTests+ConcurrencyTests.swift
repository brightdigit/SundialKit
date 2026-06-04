//
//  NetworkMonitorTests+ConcurrencyTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork

extension NetworkMonitorTests {
  // MARK: - Thread Safety Tests

  @Test("NetworkMonitor handles concurrent property access")
  func testConcurrentPropertyAccess() async {
    #if canImport(Dispatch)
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
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  @Test("NetworkMonitor handles concurrent observer operations")
  func testConcurrentObserverOperations() async {
    #if canImport(Dispatch)
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
            await monitor.removeObservers {
              ($0 as? TestNetworkStateObserver) === observerToRemove
            }
          }
        }
      }

      // If we get here without crashing, thread safety is working
      #expect(true)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }

  // MARK: - Ping Integration Tests

  @Test("NetworkMonitor integrates with ping")
  func testPingIntegration() async throws {
    #if canImport(Dispatch)
      let pathMonitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 0.1)
      let monitor = NetworkMonitor(monitor: pathMonitor, ping: ping)

      monitor.start(queue: .global())

      // Wait for potential ping to execute
      try await Task.sleep(forMilliseconds: 500)

      monitor.stop()

      // Test passes if no crashes occurred during ping execution
      #expect(true)
    #else
      Issue.record("This test requires Dispatch and should be disabled on WASM")
    #endif
  }
}
