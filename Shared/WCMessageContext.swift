enum WCMessageContext {
  case replyWith(WCMessageHandler)
  case applicationContext

  var replyHandler: WCMessageHandler? {
    guard case let .replyWith(handler) = self else {
      return nil
    }
    return handler
  }
}
