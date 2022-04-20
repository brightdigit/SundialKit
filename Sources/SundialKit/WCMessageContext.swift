public enum WCMessageContext {
  case replyWith(WCMessageHandler)
  case applicationContext

  public var replyHandler: WCMessageHandler? {
    guard case let .replyWith(handler) = self else {
      return nil
    }
    return handler
  }

  public var isApplicationContext: Bool {
    guard case .applicationContext = self else {
      return false
    }
    return true
  }
}
