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
  ///   - pollInterval: Time between checks in milliseconds (default: 50ms)
  ///   - condition: The condition to check
  /// - Throws: If the timeout expires before the condition becomes true
  internal func waitUntil(
    timeout: TimeInterval = 5,
    pollInterval: UInt64 = 50,
    _ condition: @escaping () async -> Bool
  ) async throws {
    let startTime = Date()
    let deadline = startTime.addingTimeInterval(timeout)
    var attempts = 0

    while Date() < deadline {
      attempts += 1
      if await condition() {
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed > 1.0 {
          // Log if it took more than 1 second
          print("waitUntil: condition met after \(elapsed)s (\(attempts) attempts)")
        }
        return
      }
      try await Task.sleep(forMilliseconds: pollInterval)
    }

    let elapsed = Date().timeIntervalSince(startTime)
    print("waitUntil: timeout after \(elapsed)s (\(attempts) attempts)")
    Issue.record("Timeout waiting for condition after \(elapsed)s (\(attempts) attempts)")
  }
#endif
