//
// ConnectivityReceiveContext.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// Context indicating how a message was received and how to handle it.
///
/// This enum distinguishes between interactive messages that expect a reply
/// and one-way state updates sent via application context.
///
/// ## Example
///
/// ```swift
/// // Using SundialKitStream
/// for await result in await observer.messageStream() {
///   switch result.context {
///   case .replyWith(let handler):
///     // Interactive message - send a reply
///     print("Received: \(result.message)")
///     handler(["status": "acknowledged"])
///
///   case .applicationContext:
///     // One-way update - no reply expected
///     print("State update: \(result.message)")
///   }
/// }
/// ```
public enum ConnectivityReceiveContext: Sendable {
  /// Received as an interactive message with a reply handler.
  ///
  /// The associated handler should be called to send a reply back to the sender.
  /// This corresponds to WatchConnectivity's `session(_:didReceiveMessage:replyHandler:)`.
  case replyWith(@Sendable (ConnectivityMessage) -> Void)

  /// Received as a one-way application context update.
  ///
  /// No reply is expected or possible. This corresponds to WatchConnectivity's
  /// `session(_:didReceiveApplicationContext:)`.
  case applicationContext

  /// The reply handler if it contains one.
  public var replyHandler: ConnectivityHandler? {
    guard case .replyWith(let handler) = self else {
      return nil
    }
    return handler
  }

  /// If this was from application context.
  public var isApplicationContext: Bool {
    guard case .applicationContext = self else {
      return false
    }
    return true
  }
}
