//
// ConnectivityReceiveResult.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// Result of receiving a message from WatchConnectivity.
///
/// Contains the received message payload and context about how it was received
/// (interactive with reply handler, or one-way application context update).
///
/// ## Example
///
/// ```swift
/// // Using SundialKitStream
/// for await result in await observer.messageStream() {
///   print("Received: \(result.message)")
///
///   // Handle based on context
///   if let handler = result.context.replyHandler {
///     handler(["status": "received"])
///   }
/// }
/// ```
public struct ConnectivityReceiveResult: Sendable {
  /// The message that was received.
  ///
  /// Contains the dictionary payload sent by the counterpart device.
  public let message: ConnectivityMessage

  /// Context indicating how the message was received.
  ///
  /// Determines whether this is an interactive message requiring a reply
  /// or a one-way application context update.
  public let context: ConnectivityReceiveContext

  /// Creates a new receive result.
  /// - Parameters:
  ///   - message: The message that was received
  ///   - context: How the message was received
  public init(message: ConnectivityMessage, context: ConnectivityReceiveContext) {
    self.message = message
    self.context = context
  }
}
