//
// ConnectivityActivation+Implementation.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore
  import WatchConnectivity

  // MARK: - Async Activation Implementation

  extension ConnectivityActivation where Self: Actor {
    /// Activates the connectivity session asynchronously with timeout.
    ///
    /// This method bridges the delegate-based activation callback to async/await.
    /// It waits for the session to activate or throws an error if activation fails
    /// or times out.
    ///
    /// - Parameter timeout: Maximum time to wait for activation (default: 30 seconds)
    /// - Throws: `ConnectivityError` if activation fails or times out
    public func activate(timeout: TimeInterval = 30) async throws {
      // Check if already activated
      if await activationState == .activated {
        return
      }

      return try await withCheckedThrowingContinuation { continuation in
        Task {
          // Check if activation is already in progress
          if await activationContinuation != nil {
            continuation.resume(throwing: ConnectivityError.sessionNotActivated)
            return
          }

          // Store continuation
          await setActivationContinuation(continuation)

          // Start timeout task
          let timeoutTask = Task {
            try? await Task.sleep(forMilliseconds: UInt64(timeout * 1_000))

            await handleActivationTimeout()
          }

          // Store timeout task
          await setActivationTimeoutTask(timeoutTask)

          // Activate session
          do {
            try session.activate()
          } catch {
            await handleActivationError(error)
          }

          // Note: The continuation will be resumed in the delegate callback
        }
      }
    }
  }

  // MARK: - Default Implementations for Synchronous Activation

  extension ConnectivityActivation {
    /// Default implementation for synchronous activation.
    ///
    /// - Throws: `ConnectivityError` if activation fails.
    nonisolated public func activate() throws {
      try session.activate()
    }
  }
#endif
