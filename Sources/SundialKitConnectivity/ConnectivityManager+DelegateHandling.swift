//
// ConnectivityManager+DelegateHandling.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore
  import WatchConnectivity

  // MARK: - Actor-Isolated Delegate Handling

  extension ConnectivityManager {
    // MARK: - Activation Handling

    /// Actor-isolated handler for activation completion.
    ///
    /// Updates activation state and notifies observers.
    ///
    /// - Parameters:
    ///   - state: The activation state.
    ///   - error: Any error that occurred during activation.
    internal func isolatedHandleActivation(_ state: ActivationState, error: (any Error)?) async {
      // Update activation state
      self.activationState = state

      // Resume activation continuation if present
      if let continuation = activationContinuation {
        await clearActivationState()

        if let error = error {
          // Map error to ConnectivityError
          if let wcError = error as? WCError {
            continuation.resume(throwing: ConnectivityError(wcError: wcError))
          } else {
            continuation.resume(throwing: ConnectivityError.sessionNotSupported)
          }
        } else if state == .activated {
          continuation.resume()
        } else {
          continuation.resume(throwing: ConnectivityError.sessionNotActivated)
        }
      }

      // Notify observers of activation state change
      await self.notifyActivationStateChanged(state)
    }

    /// Clears activation continuation and timeout task.
    private func clearActivationState() async {
      self.activationContinuation = nil
      self.activationTimeoutTask?.cancel()
      self.activationTimeoutTask = nil
    }

    /// Actor-isolated handler for activation state changes.
    ///
    /// - Parameter activationState: The new activation state.
    internal func isolatedActiveState(_ activationState: ActivationState) async {
      self.activationState = activationState

      // Notify observers of activation state change
      await self.notifyActivationStateChanged(activationState)
    }

    // MARK: - Reachability Handling

    /// Actor-isolated handler for reachability changes.
    ///
    /// - Parameter isReachable: The new reachability status.
    internal func isolatedReachabilityChanged(_ isReachable: Bool) async {
      self.isReachable = isReachable

      // Notify observers of reachability change
      await self.notifyReachabilityChanged(isReachable)
    }

    // MARK: - Companion State Handling

    /// Actor-isolated handler for companion state changes.
    ///
    /// - Parameter session: The connectivity session.
    internal func isolatedSessionStateChanged(_ session: any ConnectivitySession) async {
      self.isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        self.isPaired = session.isPaired
      #endif

      // Notify observers of companion state changes
      await self.notifyCompanionAppInstalledChanged(session.isPairedAppInstalled)
      #if os(iOS)
        await self.notifyPairedStatusChanged(session.isPaired)
      #endif
    }

    // MARK: - Nonisolated Delegate Methods

    /// Handles session activation completion.
    nonisolated public func handleActivation(_ state: ActivationState, error: (any Error)?) {
      Task {
        await self.isolatedHandleActivation(state, error: error)
      }
    }

    /// Handles session becoming inactive.
    nonisolated public func handleSessionInactive() {
      Task {
        await self.isolatedActiveState(.inactive)
      }
    }

    /// Handles session deactivation.
    nonisolated public func handleSessionDeactivate() {
      Task {
        await self.isolatedActiveState(.notActivated)
      }
    }

    /// Handles reachability changes.
    nonisolated public func handleReachabilityChange(_ isReachable: Bool) {
      Task {
        await self.isolatedReachabilityChanged(isReachable)
      }
    }

    /// Handles companion device state changes.
    nonisolated public func handleCompanionStateChange(_ session: any ConnectivitySession) {
      Task {
        await self.isolatedSessionStateChanged(session)
      }
    }

    /// Handles received messages.
    nonisolated public func handleMessageReceived(_ message: ConnectivityMessage) {
      Task {
        // Notify observers of received message
        await self.notifyMessageReceived(message)
      }
    }

    /// Handles application context updates.
    nonisolated public func handleApplicationContextReceived(
      _ applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      // Only notify if no error
      guard error == nil else {
        return
      }

      Task {
        // Notify observers of context update
        await self.notifyApplicationContextReceived(applicationContext)
      }
    }

    /// Handles received binary message data.
    nonisolated public func handleBinaryMessageReceived(
      _: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      // Binary messages are not currently forwarded to observers
      // Future enhancement: Could add binary message observer protocol
    }
  }
#endif
