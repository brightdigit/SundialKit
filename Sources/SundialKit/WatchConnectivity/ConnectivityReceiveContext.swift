/// Context of the message received
public enum ConnectivityReceiveContext {
  /// received as a sent message with a reploy handler
  case replyWith(ConnectivityHandler)
  /// received as application context.
  case applicationContext

  /// The reply handler if it contains one.
  public var replyHandler: ConnectivityHandler? {
    guard case let .replyWith(handler) = self else {
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
