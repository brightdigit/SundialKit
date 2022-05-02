public protocol WCSessionableDelegate: AnyObject {
  func session(
    _ session: WCSessionable,
    activationDidCompleteWith activationState: ActivationState,
    error: Error?
  )

  func sessionDidBecomeInactive(_ session: WCSessionable)

  func sessionDidDeactivate(_ session: WCSessionable)

  func sessionCompanionStateDidChange(_ session: WCSessionable)

  func sessionReachabilityDidChange(_ session: WCSessionable)

  func session(
    _ session: WCSessionable,
    didReceiveMessage message: WCMessage,
    replyHandler: @escaping WCMessageHandler
  )

  func session(
    _ session: WCSessionable,
    didReceiveApplicationContext applicationContext: WCMessage,
    error: Error?
  )
}
