//
// NeverConnectivitySession.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// A no-op implementation of `ConnectivitySession` for platforms without WatchConnectivity.
///
/// Used on macOS and tvOS where WatchConnectivity is not available.
/// All operations throw or return inactive/unavailable states.
///
/// This class is naturally Sendable as all properties are immutable computed properties.
public final class NeverConnectivitySession: NSObject, ConnectivitySession, Sendable {
  /// The delegate (always nil for this implementation).
  public var delegate: (any ConnectivitySessionDelegate)? {
    get {
      nil
    }
    // swiftlint:disable:next unused_setter_value
    set {}
  }

  /// Whether the counterpart is reachable (always false).
  public var isReachable: Bool {
    false
  }

  /// Whether devices are paired (always false).
  public var isPaired: Bool {
    false
  }

  /// Whether the counterpart app is installed (always false).
  public var isPairedAppInstalled: Bool {
    false
  }

  /// The activation state (always notActivated).
  public var activationState: ActivationState {
    .notActivated
  }

  /// The most recent application context (always nil).
  public var receivedApplicationContext: ConnectivityMessage? {
    nil
  }

  /// Attempts to activate the session (always throws).
  ///
  /// - Throws: `SundialError.sessionNotSupported`
  public func activate() throws {
    throw SundialError.sessionNotSupported
  }

  /// Attempts to update application context (always throws).
  ///
  /// - Throws: `SundialError.sessionNotSupported`
  public func updateApplicationContext(_: ConnectivityMessage) throws {
    throw SundialError.sessionNotSupported
  }

  /// Attempts to send a message (always fails).
  public func sendMessage(
    _: ConnectivityMessage,
    _ completion: @escaping (Result<ConnectivityMessage, any Error>) -> Void
  ) {
    completion(.failure(SundialError.sessionNotSupported))
  }

  /// Attempts to send binary message data (always fails).
  public func sendMessageData(
    _: Data,
    _ completion: @escaping (Result<Data, any Error>) -> Void
  ) {
    completion(.failure(SundialError.sessionNotSupported))
  }
}
