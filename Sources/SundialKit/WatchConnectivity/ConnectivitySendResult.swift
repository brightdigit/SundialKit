/// The result from sending a message.
public struct ConnectivitySendResult {
  /// The reply message sent.
  public let message: ConnectivityMessage

  /// How the message was sent.
  public let context: ConnectivitySendContext
}
