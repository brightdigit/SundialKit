//
// ConnectivityStateObserver.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore

  /// Protocol for observing connectivity state changes.
  ///
  /// Implement this protocol to receive notifications about changes in
  /// WatchConnectivity session state, reachability, and companion status.
  ///
  /// Observers must be Sendable (actors, @MainActor classes, or value types).
  /// All delegate methods are nonisolated. Observers are responsible for thread
  /// management - use @MainActor on your observer class/actor for UI-related work.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityStateObserver: Sendable {
    /// Called when the activation state changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - activationState: The new activation state
    nonisolated func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeActivationState activationState: ActivationState
    )

    /// Called when reachability changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - isReachable: Whether the counterpart is now reachable
    nonisolated func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeReachability isReachable: Bool
    )

    /// Called when companion app installation status changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - isInstalled: Whether the companion app is installed
    nonisolated func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeCompanionAppInstalled isInstalled: Bool
    )

    #if os(iOS)
      /// Called when the paired status changes (iOS only).
      ///
      /// - Parameters:
      ///   - manager: The connectivity manager
      ///   - isPaired: Whether an Apple Watch is paired
      nonisolated func connectivityManager(
        _ manager: ConnectivityManager,
        didChangePairedStatus isPaired: Bool
      )
    #endif

    /// Called when a message is received from the counterpart.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - message: The received message
    nonisolated func connectivityManager(
      _ manager: ConnectivityManager,
      didReceiveMessage message: ConnectivityMessage
    )

    /// Called when an application context update is received.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - context: The updated application context
    nonisolated func connectivityManager(
      _ manager: ConnectivityManager,
      didReceiveApplicationContext context: ConnectivityMessage
    )
  }

  // Default implementations to make all methods optional
  extension ConnectivityStateObserver {
    /// Default implementation that does nothing.
    ///
    /// Override this method to respond to activation state changes.
    public func connectivityManager(
      _: ConnectivityManager,
      didChangeActivationState _: ActivationState
    ) {}

    /// Default implementation that does nothing.
    ///
    /// Override this method to respond to reachability changes.
    public func connectivityManager(
      _: ConnectivityManager,
      didChangeReachability _: Bool
    ) {}

    /// Default implementation that does nothing.
    ///
    /// Override this method to respond to companion app installation status changes.
    public func connectivityManager(
      _: ConnectivityManager,
      didChangeCompanionAppInstalled _: Bool
    ) {}

    #if os(iOS)
      /// Default implementation that does nothing.
      ///
      /// Override this method to respond to paired status changes (iOS only).
      public func connectivityManager(
        _: ConnectivityManager,
        didChangePairedStatus _: Bool
      ) {}
    #endif

    /// Default implementation that does nothing.
    ///
    /// Override this method to respond to received messages.
    public func connectivityManager(
      _: ConnectivityManager,
      didReceiveMessage _: ConnectivityMessage
    ) {}

    /// Default implementation that does nothing.
    ///
    /// Override this method to respond to application context updates.
    public func connectivityManager(
      _: ConnectivityManager,
      didReceiveApplicationContext _: ConnectivityMessage
    ) {}
  }
#endif
