//
//  ConnectivityManager.swift
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

  /// Non-reactive manager for WatchConnectivity sessions.
  ///
  /// `ConnectivityManager` provides a protocol-based abstraction over Apple's
  /// WatchConnectivity framework without Combine dependencies. It manages session
  /// lifecycle, message routing, and state changes through an observer pattern.
  ///
  /// ## Thread Safety
  ///
  /// This actor ensures thread-safe access to session state. Public methods are
  /// `nonisolated` where appropriate and use Tasks internally for actor-isolated
  /// operations, providing a synchronous API while maintaining thread safety.
  ///
  /// ## Usage
  ///
  /// ```swift
  /// let manager = ConnectivityManager()
  /// try manager.activate()
  ///
  /// // Send a message
  /// manager.sendMessage(
  ///   ["key": "value"],
  ///   replyHandler: { reply in
  ///     print("Reply: \(reply)")
  ///   },
  ///   errorHandler: { error in
  ///     print("Error: \(error)")
  ///   }
  /// )
  /// ```
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public actor ConnectivityManager:
    ConnectivityManagement,
    ConnectivityMessaging,
    ConnectivityObserverManaging,
    ConnectivityDelegateHandling,
    ConnectivitySessionDelegate
  {
    // MARK: - Properties

    /// The underlying connectivity session.
    public let session: any ConnectivitySession

    /// Storage for activation continuation during async activation.
    private var activationContinuation: CheckedContinuation<Void, any Error>?

    /// Storage for activation timeout task.
    private var activationTimeoutTask: Task<Void, Never>?

    /// Registry for managing observer references.
    public let observerRegistry = ObserverRegistry<any ConnectivityStateObserver>()

    // MARK: - ConnectivityManagement Protocol

    /// The current activation state of the connectivity session.
    public var activationState: ActivationState = .notActivated

    /// Indicates whether the counterpart device is currently reachable.
    public var isReachable: Bool = false

    /// Indicates whether the companion app is installed on the paired device.
    public var isPairedAppInstalled: Bool = false

    #if os(iOS)
      /// Indicates whether an Apple Watch is currently paired with this iPhone.
      public var isPaired: Bool = false
    #endif

    // MARK: - Initialization

    /// Creates a connectivity manager with the specified session.
    ///
    /// - Parameter session: The connectivity session to manage.
    public init(session: any ConnectivitySession) {
      self.session = session

      // Initialize state from session
      self.activationState = session.activationState
      self.isReachable = session.isReachable
      self.isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        self.isPaired = session.isPaired
      #endif
      self.session.delegate = self
    }

    /// Creates a connectivity manager with the default WatchConnectivity session.
    public init() {
      self.init(session: WatchConnectivitySession())
    }

    // MARK: - Session Lifecycle

    /// Activates the connectivity session.
    ///
    /// - Throws: `ConnectivityError` if activation fails.
    public nonisolated func activate() throws {
      try session.activate()
    }

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
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))

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

    // MARK: - Private Activation Helpers

    private func setActivationContinuation(_ continuation: CheckedContinuation<Void, any Error>) {
      activationContinuation = continuation
    }

    private func setActivationTimeoutTask(_ task: Task<Void, Never>) {
      activationTimeoutTask = task
    }

    private func handleActivationTimeout() {
      if let storedContinuation = activationContinuation {
        activationContinuation = nil
        activationTimeoutTask = nil
        storedContinuation.resume(throwing: ConnectivityError.transferTimedOut)
      }
    }

    private func handleActivationError(_ error: any Error) {
      if let storedContinuation = activationContinuation {
        activationContinuation = nil
        activationTimeoutTask?.cancel()
        activationTimeoutTask = nil

        // Map error to ConnectivityError
        if let wcError = error as? WCError {
          storedContinuation.resume(throwing: ConnectivityError(wcError: wcError))
        } else {
          storedContinuation.resume(throwing: ConnectivityError.sessionNotSupported)
        }
      }
    }

    // MARK: - ConnectivityMessaging Protocol

    /// Sends a message to the counterpart device.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Called when a reply is received.
    ///   - errorHandler: Called if sending fails.
    public nonisolated func sendMessage(
      _ message: ConnectivityMessage,
      replyHandler: @escaping (ConnectivityMessage) -> Void,
      errorHandler: @escaping (any Error) -> Void
    ) {
      session.sendMessage(message) { result in
        switch result {
        case .success(let reply):
          replyHandler(reply)
        case .failure(let error):
          errorHandler(error)
        }
      }
    }

    /// Updates the application context.
    ///
    /// - Parameter context: The context dictionary to send.
    /// - Throws: `ConnectivityError` if the update fails.
    public nonisolated func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context)
    }

    // MARK: - ConnectivityObserverManaging Protocol

    /// Adds an observer for state changes.
    ///
    /// - Parameter observer: The observer to add.
    /// - Note: Observers are stored with strong references - caller must manage lifecycle.
    public nonisolated func addObserver(_ observer: any ConnectivityStateObserver) {
      Task {
        await observerRegistry.add(observer)
      }
    }

    /// Removes observers matching the predicate.
    ///
    /// - Parameter predicate: Closure to identify observers to remove.
    public nonisolated func removeObservers(
      where predicate: @Sendable @escaping (any ConnectivityStateObserver) -> Bool
    ) {
      Task {
        await observerRegistry.removeAll(where: predicate)
      }
    }

    // MARK: - ConnectivityDelegateHandling Protocol

    private func isolatedHandleActivation(_ state: ActivationState, error: (any Error)?) {
      // Update activation state
      self.activationState = state

      // Resume activation continuation if present
      if let continuation = activationContinuation {
        activationContinuation = nil
        activationTimeoutTask?.cancel()
        activationTimeoutTask = nil

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
      notifyActivationStateChanged(state)
    }
    /// Handles session activation completion.
    public nonisolated func handleActivation(_ state: ActivationState, error: (any Error)?) {
      Task {
        await self.isolatedHandleActivation(state, error: error)
      }
    }

    fileprivate func isolatedActiveState(_ activationState: ActivationState) {
      self.activationState = activationState

      // Notify observers of activation state change
      notifyActivationStateChanged(activationState)
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

    private func isolatedReachabilityChanged(_ isReachable: Bool) {
      self.isReachable = isReachable

      // Notify observers of reachability change
      notifyReachabilityChanged(isReachable)
    }

    /// Handles companion device state changes.
    public nonisolated func handleCompanionStateChange(_ session: any ConnectivitySession) {
      Task {
        await self.isolatedSessionStateChanged(session)
      }
    }

    private func isolatedSessionStateChanged(_ session: any ConnectivitySession) {
      self.isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        self.isPaired = session.isPaired
      #endif

      // Notify observers of companion state changes
      notifyCompanionAppInstalledChanged(isPairedAppInstalled)
      #if os(iOS)
        notifyPairedStatusChanged(isPaired)
      #endif
    }

    /// Handles received messages.
    public nonisolated func handleMessageReceived(_ message: ConnectivityMessage) {
      // Notify observers of received message
      notifyMessageReceived(message)
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
      notifyApplicationContextReceived(applicationContext)
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
