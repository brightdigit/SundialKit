//
//  ConnectivityManagerTestHelpers.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  #if canImport(os)
    import os.log
  #endif
  import SundialKitCore
  import Testing

  // MARK: - Test Helpers

  /// Waits for a condition to become true, polling at regular intervals.
  ///
  /// - Parameters:
  ///   - timeout: Maximum time to wait in seconds (default: 10)
  ///   - pollInterval: Time between checks in milliseconds (default: 50ms)
  ///   - condition: The condition to check
  /// - Throws: If the timeout expires before the condition becomes true
  internal func waitUntil(
    timeout: TimeInterval = 10,
    pollInterval: UInt64 = 50,
    _ condition: @escaping () async -> Bool
  ) async throws {
    let startTime = Date()
    let deadline = startTime.addingTimeInterval(timeout)
    var attempts = 0

    while Date() < deadline {
      attempts += 1
      // Yield to allow pending tasks to execute before checking condition
      await Task.yield()
      if await condition() {
        let elapsed = Date().timeIntervalSince(startTime)
        if elapsed > 1.0 {
          // Log if it took more than 1 second
          if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            SundialLogger.test.debug(
              "waitUntil: condition met after \(elapsed)s (\(attempts) attempts)"
            )
          }
        }
        return
      }
      try await Task.sleep(forMilliseconds: pollInterval)
    }

    let elapsed = Date().timeIntervalSince(startTime)
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      SundialLogger.test.debug("waitUntil: timeout after \(elapsed)s (\(attempts) attempts)")
    }
    Issue.record("Timeout waiting for condition after \(elapsed)s (\(attempts) attempts)")
  }
#endif
