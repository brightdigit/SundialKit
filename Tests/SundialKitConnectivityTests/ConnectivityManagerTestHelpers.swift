//
//  ConnectivityManagerTestHelpers.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  import SundialKitCore
  import Testing

  // MARK: - Test Helpers

  /// Waits for a condition to become true, polling at regular intervals.
  ///
  /// - Parameters:
  ///   - timeout: Maximum time to wait in seconds (default: 5)
  ///   - pollInterval: Time between checks in milliseconds (default: 10ms)
  ///   - condition: The condition to check
  /// - Throws: If the timeout expires before the condition becomes true
  internal func waitUntil(
    timeout: TimeInterval = 5,
    pollInterval: UInt64 = 10,
    _ condition: @escaping () async -> Bool
  ) async throws {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if await condition() {
        return
      }
      try await Task.sleep(forMilliseconds: pollInterval)
    }
    Issue.record("Timeout waiting for condition")
  }
#endif
