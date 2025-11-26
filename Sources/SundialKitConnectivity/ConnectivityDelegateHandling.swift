//
// ConnectivityDelegateHandling.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore
  import WatchConnectivity

  /// Protocol for handling connectivity session delegate callbacks.
  ///
  /// This protocol defines handler methods that process session state changes
  /// and received data from WatchConnectivity.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityDelegateHandling {
    /// Handles session activation completion.
    ///
    /// - Parameters:
    ///   - state: The activation state.
    ///   - error: Any error that occurred during activation.
    func handleActivation(_ state: ActivationState, error: (any Error)?)

    /// Handles session becoming inactive.
    func handleSessionInactive()

    /// Handles session deactivation.
    func handleSessionDeactivate()

    /// Handles reachability changes.
    ///
    /// - Parameter isReachable: Whether the counterpart is now reachable.
    func handleReachabilityChange(_ isReachable: Bool)

    /// Handles companion device state changes.
    ///
    /// - Parameter session: The connectivity session.
    func handleCompanionStateChange(_ session: any ConnectivitySession)

    /// Handles received messages.
    ///
    /// - Parameter message: The received message.
    func handleMessageReceived(_ message: ConnectivityMessage)

    /// Handles application context updates.
    ///
    /// - Parameters:
    ///   - applicationContext: The updated context.
    ///   - error: Any error that occurred.
    func handleApplicationContextReceived(
      _ applicationContext: ConnectivityMessage,
      error: (any Error)?
    )

    /// Handles received binary message data.
    ///
    /// - Parameters:
    ///   - messageData: The received binary data.
    ///   - replyHandler: Handler for sending a reply.
    func handleBinaryMessageReceived(
      _ messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    )
  }

  // MARK: - ConnectivitySessionDelegate Bridge

  extension ConnectivityDelegateHandling
  where Self: ConnectivityManager & ConnectivityObserverManaging {
    /// Called when session activation completes.
    public func session(
      _: any ConnectivitySession,
      activationDidCompleteWith activationState: ActivationState,
      error: (any Error)?
    ) {
      self.handleActivation(activationState, error: error)
    }

    /// Called when the session becomes inactive (iOS only).
    public func sessionDidBecomeInactive(_: any ConnectivitySession) {
      handleSessionInactive()
    }

    /// Called when the session deactivates (iOS only).
    public func sessionDidDeactivate(_: any ConnectivitySession) {
      handleSessionDeactivate()
    }

    /// Called when companion state changes.
    public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
      handleCompanionStateChange(session)
    }

    /// Called when reachability changes.
    public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
      handleReachabilityChange(session.isReachable)
    }

    /// Called when a message is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveMessage message: ConnectivityMessage,
      replyHandler: @escaping ConnectivityHandler
    ) {
      handleMessageReceived(message)
    }

    /// Called when application context is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      handleApplicationContextReceived(applicationContext, error: error)
    }

    /// Called when binary message data is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveMessageData messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      handleBinaryMessageReceived(messageData, replyHandler: replyHandler)
    }
  }
#endif
