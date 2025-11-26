//
// ConnectivitySendResult.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// Result of sending a message via WatchConnectivity.
///
/// Contains the reply message (if any) and context about how the message was sent
/// (direct message with reply, application context, or failure).
///
/// ## Example
///
/// ```swift
/// let result = try await observer.send(ColorMessage(red: 1.0, green: 0, blue: 0))
///
/// switch result.context {
/// case .reply(let replyMessage, let transport):
///   print("Sent via \(transport), reply: \(replyMessage)")
///
/// case .applicationContext(let transport):
///   print("Queued via application context using \(transport)")
///
/// case .failure(let error):
///   print("Failed: \(error)")
/// }
/// ```
public struct ConnectivitySendResult: Sendable {
  /// The reply message received from the counterpart, if any.
  ///
  /// Contains the dictionary payload in the reply. For `.applicationContext` sends,
  /// this will be empty since application context doesn't support replies.
  public let message: ConnectivityMessage

  /// Context indicating how the message was sent and the outcome.
  ///
  /// Includes the transport mechanism used (dictionary vs binary) and whether
  /// a reply was received or the message was queued via application context.
  public let context: ConnectivitySendContext

  /// Creates a new send result.
  /// - Parameters:
  ///   - message: The message that was sent
  ///   - context: How the message was sent
  public init(message: ConnectivityMessage, context: ConnectivitySendContext) {
    self.message = message
    self.context = context
  }
}
