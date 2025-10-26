//
//  ConnectivityManager+DelegateHandling.swift
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
      self.notifyActivationStateChanged(state)
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
      self.notifyActivationStateChanged(activationState)
    }

    // MARK: - Reachability Handling

    /// Actor-isolated handler for reachability changes.
    ///
    /// - Parameter isReachable: The new reachability status.
    internal func isolatedReachabilityChanged(_ isReachable: Bool) async {
      self.isReachable = isReachable

      // Notify observers of reachability change
      self.notifyReachabilityChanged(isReachable)
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
      self.notifyCompanionAppInstalledChanged(session.isPairedAppInstalled)
      #if os(iOS)
        self.notifyPairedStatusChanged(session.isPaired)
      #endif
    }

    // MARK: - Nonisolated Delegate Methods

    /// Handles session activation completion.
    public nonisolated func handleActivation(_ state: ActivationState, error: (any Error)?) {
      Task {
        await self.isolatedHandleActivation(state, error: error)
      }
    }

    /// Handles session becoming inactive.
    public nonisolated func handleSessionInactive() {
      Task {
        await self.isolatedActiveState(.inactive)
      }
    }

    /// Handles session deactivation.
    public nonisolated func handleSessionDeactivate() {
      Task {
        await self.isolatedActiveState(.notActivated)
      }
    }

    /// Handles reachability changes.
    public nonisolated func handleReachabilityChange(_ isReachable: Bool) {
      Task {
        await self.isolatedReachabilityChanged(isReachable)
      }
    }

    /// Handles companion device state changes.
    public nonisolated func handleCompanionStateChange(_ session: any ConnectivitySession) {
      Task {
        await self.isolatedSessionStateChanged(session)
      }
    }

    /// Handles received messages.
    public nonisolated func handleMessageReceived(_ message: ConnectivityMessage) {
      // Notify observers of received message
      self.notifyMessageReceived(message)
    }

    /// Handles application context updates.
    public nonisolated func handleApplicationContextReceived(
      _ applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      // Only notify if no error
      guard error == nil else {
        return
      }

      // Notify observers of context update
      self.notifyApplicationContextReceived(applicationContext)
    }

    /// Handles received binary message data.
    public nonisolated func handleBinaryMessageReceived(
      _: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      // Binary messages are not currently forwarded to observers
      // Future enhancement: Could add binary message observer protocol
    }
  }
#endif
