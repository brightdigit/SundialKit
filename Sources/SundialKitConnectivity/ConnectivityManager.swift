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
  public final class ConnectivityManager: ConnectivityManagement, ConnectivitySessionDelegate {
    // MARK: - Properties

    /// The underlying connectivity session.
    private let session: any ConnectivitySession

    /// Lock for thread-safe access to mutable state.
    private let lock = NSLock()

    /// Storage for activation continuation during async activation.
    private var activationContinuation: CheckedContinuation<Void, any Error>?

    /// Storage for activation timeout task.
    private var activationTimeoutTask: Task<Void, Never>?

    /// Current activation state of the session.
    private var internalActivationState: ActivationState = .notActivated

    /// Current reachability status.
    private var internalIsReachable = false

    /// Whether the companion app is installed.
    private var internalIsPairedAppInstalled = false

    #if os(iOS)
      /// Whether an Apple Watch is paired (iOS only).
      private var internalIsPaired = false
    #endif

    /// Weak references to registered observers.
    private var observers = NSHashTable<AnyObject>.weakObjects()

    // MARK: - ConnectivityManagement Protocol

    /// The current activation state of the connectivity session.
    public var activationState: ActivationState {
      lock.lock()
      defer { lock.unlock() }
      return internalActivationState
    }

    /// Indicates whether the counterpart device is currently reachable.
    public var isReachable: Bool {
      lock.lock()
      defer { lock.unlock() }
      return internalIsReachable
    }

    /// Indicates whether the companion app is installed on the paired device.
    public var isPairedAppInstalled: Bool {
      lock.lock()
      defer { lock.unlock() }
      return internalIsPairedAppInstalled
    }

    #if os(iOS)
      /// Indicates whether an Apple Watch is currently paired with this iPhone.
      public var isPaired: Bool {
        lock.lock()
        defer { lock.unlock() }
        return internalIsPaired
      }
    #endif

    // MARK: - Initialization

    /// Creates a connectivity manager with the specified session.
    ///
    /// - Parameter session: The connectivity session to manage.
    public init(session: any ConnectivitySession) {
      self.session = session
      self.session.delegate = self

      // Initialize state from session
      lock.lock()
      internalActivationState = session.activationState
      internalIsReachable = session.isReachable
      internalIsPairedAppInstalled = session.isPairedAppInstalled
      internalIsPaired = session.isPaired
      lock.unlock()
    }

    /// Creates a connectivity manager with the default WatchConnectivity session.
    public convenience init() {
      self.init(session: WatchConnectivitySession())
    }

    // MARK: - Session Lifecycle

    /// Activates the connectivity session.
    ///
    /// - Throws: `ConnectivityError` if activation fails.
    public func activate() throws {
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
      if activationState == .activated {
        return
      }

      return try await withCheckedThrowingContinuation { continuation in
        lock.lock()

        // Check if activation is already in progress
        if activationContinuation != nil {
          lock.unlock()
          continuation.resume(throwing: ConnectivityError.sessionNotActivated)
          return
        }

        // Store continuation
        activationContinuation = continuation
        lock.unlock()

        // Start timeout task
        let timeoutTask = Task {
          try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))

          lock.lock()
          if let storedContinuation = activationContinuation {
            activationContinuation = nil
            activationTimeoutTask = nil
            lock.unlock()
            storedContinuation.resume(throwing: ConnectivityError.transferTimedOut)
          } else {
            lock.unlock()
          }
        }

        // Store timeout task
        lock.lock()
        activationTimeoutTask = timeoutTask
        lock.unlock()

        // Activate session
        do {
          try session.activate()
        } catch {
          lock.lock()
          if let storedContinuation = activationContinuation {
            activationContinuation = nil
            activationTimeoutTask?.cancel()
            activationTimeoutTask = nil
            lock.unlock()

            // Map error to ConnectivityError
            if let wcError = error as? WCError {
              storedContinuation.resume(throwing: ConnectivityError(wcError: wcError))
            } else {
              storedContinuation.resume(throwing: ConnectivityError.sessionNotSupported)
            }
          } else {
            lock.unlock()
          }
        }

        // Note: The continuation will be resumed in the delegate callback
      }
    }

    // MARK: - Messaging

    /// Sends a message to the counterpart device.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Called when a reply is received.
    ///   - errorHandler: Called if sending fails.
    public func sendMessage(
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
      // Validate message size (65KB limit for WatchConnectivity)
      let maxSize = 65_536
      if let data = try? JSONSerialization.data(withJSONObject: message),
        data.count > maxSize
      {
        throw ConnectivityError.payloadTooLarge
      }

      // Check reachability
      if isReachable {
        // Use sendMessage for immediate delivery with reply
        return try await withCheckedThrowingContinuation { continuation in
          var didResume = false
          let lock = NSLock()

          // Set up timeout
          let timeoutTask = Task {
            try await Task.sleep(nanoseconds: UInt64(replyTimeout * 1_000_000_000))

            lock.lock()
            if !didResume {
              didResume = true
              lock.unlock()
              continuation.resume(throwing: ConnectivityError.messageReplyTimedOut)
            } else {
              lock.unlock()
            }
          }

          // Send message
          session.sendMessage(message) { result in
            lock.lock()
            if !didResume {
              didResume = true
              lock.unlock()
              timeoutTask.cancel()

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
            } else {
              lock.unlock()
            }
          }
        }
      } else if isPairedAppInstalled {
        // Fallback to updateApplicationContext when not reachable
        try updateApplicationContext(message)
        // Return empty dictionary since context update has no reply
        return [:]
      } else {
        // Companion is not available
        throw ConnectivityError.companionAppNotInstalled
      }
    }

    /// Updates the application context.
    ///
    /// - Parameter context: The context dictionary to send.
    /// - Throws: `ConnectivityError` if the update fails.
    public func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context)
    }

    // MARK: - ConnectivitySessionDelegate

    /// Called when session activation completes.
    public func session(
      _ session: any ConnectivitySession,
      activationDidCompleteWith activationState: ActivationState,
      error: (any Error)?
    ) {
      lock.lock()
      internalActivationState = activationState

      // Resume activation continuation if present
      if let continuation = activationContinuation {
        activationContinuation = nil
        activationTimeoutTask?.cancel()
        activationTimeoutTask = nil
        lock.unlock()

        if let error = error {
          // Map error to ConnectivityError
          if let wcError = error as? WCError {
            continuation.resume(throwing: ConnectivityError(wcError: wcError))
          } else {
            continuation.resume(throwing: ConnectivityError.sessionNotSupported)
          }
        } else if activationState == .activated {
          continuation.resume()
        } else {
          continuation.resume(throwing: ConnectivityError.sessionNotActivated)
        }
      } else {
        lock.unlock()
      }

      // Notify observers of activation state change
      notifyActivationStateChanged(activationState)
    }

    /// Called when the session becomes inactive (iOS only).
    public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
      lock.lock()
      internalActivationState = .inactive
      lock.unlock()

      // Notify observers of activation state change
      notifyActivationStateChanged(.inactive)
    }

    /// Called when the session deactivates (iOS only).
    public func sessionDidDeactivate(_ session: any ConnectivitySession) {
      lock.lock()
      internalActivationState = .notActivated
      lock.unlock()

      // Notify observers of activation state change
      notifyActivationStateChanged(.notActivated)
    }

    /// Called when companion state changes.
    public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
      lock.lock()
      internalIsPairedAppInstalled = session.isPairedAppInstalled
      let appInstalled = internalIsPairedAppInstalled
      #if os(iOS)
        internalIsPaired = session.isPaired
        let paired = internalIsPaired
      #endif
      lock.unlock()

      // Notify observers of companion state changes
      notifyCompanionAppInstalledChanged(appInstalled)
      #if os(iOS)
        notifyPairedStatusChanged(paired)
      #endif
    }

    /// Called when reachability changes.
    public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
      lock.lock()
      internalIsReachable = session.isReachable
      let reachable = internalIsReachable
      lock.unlock()

      // Notify observers of reachability change
      notifyReachabilityChanged(reachable)
    }

    /// Called when a message is received.
    public func session(
      _ session: any ConnectivitySession,
      didReceiveMessage message: ConnectivityMessage,
      replyHandler: @escaping ConnectivityHandler
    ) {
      // Notify observers of received message
      notifyMessageReceived(message)
    }

    /// Called when application context is received.
    public func session(
      _ session: any ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      // Only notify if no error
      guard error == nil else { return }

      // Notify observers of context update
      notifyApplicationContextReceived(applicationContext)
    }

    /// Called when binary message data is received.
    public func session(
      _ session: any ConnectivitySession,
      didReceiveMessageData messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      // Binary messages are not currently forwarded to observers
      // Future enhancement: Could add binary message observer protocol
    }

    // MARK: - Observer Management

    /// Adds an observer for state changes.
    ///
    /// - Parameter observer: The observer to add.
    /// - Note: Observers are stored with weak references and must conform to
    ///   `ConnectivityStateObserver`.
    public func addObserver(_ observer: any ConnectivityStateObserver) {
      lock.lock()
      observers.add(observer)
      lock.unlock()
    }

    /// Removes an observer.
    ///
    /// - Parameter observer: The observer to remove.
    public func removeObserver(_ observer: any ConnectivityStateObserver) {
      lock.lock()
      observers.remove(observer)
      lock.unlock()
    }

    // MARK: - Private Notification Methods

    /// Notifies observers of activation state change on main queue.
    private func notifyActivationStateChanged(_ state: ActivationState) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        lock.lock()
        let currentObservers = observers.allObjects
        lock.unlock()

        for observer in currentObservers {
          guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
            continue
          }
          stateObserver.connectivityManager(self, didChangeActivationState: state)
        }
      }
    }

    /// Notifies observers of reachability change on main queue.
    private func notifyReachabilityChanged(_ isReachable: Bool) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        lock.lock()
        let currentObservers = observers.allObjects
        lock.unlock()

        for observer in currentObservers {
          guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
            continue
          }
          stateObserver.connectivityManager(self, didChangeReachability: isReachable)
        }
      }
    }

    /// Notifies observers of companion app installation status change on main queue.
    private func notifyCompanionAppInstalledChanged(_ isInstalled: Bool) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        lock.lock()
        let currentObservers = observers.allObjects
        lock.unlock()

        for observer in currentObservers {
          guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
            continue
          }
          stateObserver.connectivityManager(
            self,
            didChangeCompanionAppInstalled: isInstalled
          )
        }
      }
    }

    #if os(iOS)
      /// Notifies observers of paired status change on main queue (iOS only).
      private func notifyPairedStatusChanged(_ isPaired: Bool) {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else { return }
          lock.lock()
          let currentObservers = observers.allObjects
          lock.unlock()

          for observer in currentObservers {
            guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
              continue
            }
            stateObserver.connectivityManager(self, didChangePairedStatus: isPaired)
          }
        }
      }
    #endif

    /// Notifies observers of received message on main queue.
    private func notifyMessageReceived(_ message: ConnectivityMessage) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        lock.lock()
        let currentObservers = observers.allObjects
        lock.unlock()

        for observer in currentObservers {
          guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
            continue
          }
          stateObserver.connectivityManager(self, didReceiveMessage: message)
        }
      }
    }

    /// Notifies observers of application context update on main queue.
    private func notifyApplicationContextReceived(_ context: ConnectivityMessage) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        lock.lock()
        let currentObservers = observers.allObjects
        lock.unlock()

        for observer in currentObservers {
          guard let stateObserver = observer as? (any ConnectivityStateObserver) else {
            continue
          }
          stateObserver.connectivityManager(self, didReceiveApplicationContext: context)
        }
      }
    }
  }
#endif
