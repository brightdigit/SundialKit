//
//  ConnectivityMessaging.swift
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

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore
  import WatchConnectivity

  /// Protocol defining messaging capabilities for connectivity management.
  ///
  /// This protocol abstracts message sending and application context updates
  /// for WatchConnectivity sessions.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityMessaging {
    /// The underlying connectivity session.
    var session: any ConnectivitySession { get }

    /// Indicates whether the counterpart device is currently reachable.
    var isReachable: Bool { get async }

    /// Indicates whether the companion app is installed on the paired device.
    var isPairedAppInstalled: Bool { get async }

    /// Sends a message to the counterpart device.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Called when a reply is received.
    ///   - errorHandler: Called if sending fails.
    func sendMessage(
      _ message: ConnectivityMessage,
      replyHandler: @escaping (ConnectivityMessage) -> Void,
      errorHandler: @escaping (any Error) -> Void
    )

    /// Updates the application context.
    ///
    /// - Parameter context: The context dictionary to send.
    /// - Throws: `ConnectivityError` if the update fails.
    func updateApplicationContext(_ context: ConnectivityMessage) throws
  }

  // MARK: - Default Implementation for Async Send

  extension ConnectivityMessaging {
    /// Sends a message with intelligent routing and timeout handling.
    ///
    /// This method implements smart message routing:
    /// - When reachable: Uses `sendMessage` for immediate delivery with reply
    /// - When not reachable but app installed: Falls back to `updateApplicationContext`
    /// - When companion unavailable: Throws `ConnectivityError`
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send (max 65KB)
    ///   - replyTimeout: Maximum time to wait for reply (default: 10 seconds)
    /// - Returns: The reply message if reachable, empty dictionary if context updated
    /// - Throws: `ConnectivityError` if message cannot be delivered
    public func send(
      message: ConnectivityMessage,
      replyTimeout: TimeInterval = 10
    ) async throws -> ConnectivityMessage {
      try await sendWithRouting(message: message, replyTimeout: replyTimeout)
    }

    /// Internal helper for message routing with timeout.
    private func sendWithRouting(
      message: ConnectivityMessage,
      replyTimeout: TimeInterval
    ) async throws -> ConnectivityMessage {
      // Validate message size (65KB limit for WatchConnectivity)
      let maxSize = 65_536
      if let data = try? JSONSerialization.data(withJSONObject: message),
        data.count > maxSize
      {
        throw ConnectivityError.payloadTooLarge
      }

      // Check reachability
      if await isReachable {
        // Use sendMessage for immediate delivery with reply
        return try await sendWithTimeout(message: message, timeout: replyTimeout)
      } else if await isPairedAppInstalled {
        // Fallback to updateApplicationContext when not reachable
        try updateApplicationContext(message)
        // Return empty dictionary since context update has no reply
        return [:]
      } else {
        // Companion is not available
        throw ConnectivityError.companionAppNotInstalled
      }
    }

    /// Sends a message with timeout handling using structured concurrency.
    ///
    /// Uses TaskGroup to race between timeout and message delivery, eliminating
    /// the need for manual synchronization with locks.
    private func sendWithTimeout(
      message: ConnectivityMessage,
      timeout: TimeInterval
    ) async throws -> ConnectivityMessage {
      let currentSession = await session

      return try await withThrowingTaskGroup(of: ConnectivityMessage.self) { group in
        // Add timeout task
        group.addTask {
          try await Task.sleep(forMilliseconds: UInt64(timeout * 1_000))
          throw ConnectivityError.messageReplyTimedOut
        }

        // Add message sending task
        group.addTask {
          try await withCheckedThrowingContinuation { continuation in
            currentSession.sendMessage(message) { result in
              switch result {
              case .success(let reply):
                continuation.resume(returning: reply)
              case .failure(let error):
                if let wcError = error as? WCError {
                  continuation.resume(throwing: ConnectivityError(wcError: wcError))
                } else {
                  continuation.resume(throwing: ConnectivityError.deliveryFailed)
                }
              }
            }
          }
        }

        // Wait for first result (either timeout or message response)
        guard let result = try await group.next() else {
          throw ConnectivityError.deliveryFailed
        }

        // Cancel remaining tasks
        group.cancelAll()

        return result
      }
    }
  }
#endif
