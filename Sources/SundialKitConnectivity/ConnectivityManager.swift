//
// ConnectivityManager.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
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
    ConnectivityActivation,
    ConnectivitySessionDelegate
  {
    // MARK: - Properties

    /// The underlying connectivity session.
    public let session: any ConnectivitySession

    /// Storage for activation continuation during async activation.
    public var activationContinuation: CheckedContinuation<Void, any Error>?

    /// Storage for activation timeout task.
    public var activationTimeoutTask: Task<Void, Never>?

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

    // MARK: - ConnectivityActivation Protocol Helpers

    /// Sets the activation continuation.
    ///
    /// - Parameter continuation: The continuation to store.
    public func setActivationContinuation(
      _ continuation: CheckedContinuation<Void, any Error>
    ) {
      activationContinuation = continuation
    }

    /// Sets the activation timeout task.
    ///
    /// - Parameter task: The timeout task to store.
    public func setActivationTimeoutTask(_ task: Task<Void, Never>) {
      activationTimeoutTask = task
    }

    /// Handles activation timeout by resuming the stored continuation with an error.
    public func handleActivationTimeout() {
      if let storedContinuation = activationContinuation {
        activationContinuation = nil
        activationTimeoutTask = nil
        storedContinuation.resume(throwing: ConnectivityError.transferTimedOut)
      }
    }

    /// Handles activation errors by resuming the stored continuation.
    ///
    /// - Parameter error: The error that occurred during activation.
    public func handleActivationError(_ error: any Error) {
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
  }
#endif
