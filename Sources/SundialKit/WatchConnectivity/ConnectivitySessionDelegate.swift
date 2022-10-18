internal protocol ConnectivitySessionDelegate: AnyObject {
  func session(
    _ session: ConnectivitySession,
    activationDidCompleteWith activationState: ActivationState,
    error: Error?
  )

  func sessionDidBecomeInactive(_ session: ConnectivitySession)

  func sessionDidDeactivate(_ session: ConnectivitySession)

  func sessionCompanionStateDidChange(_ session: ConnectivitySession)

  func sessionReachabilityDidChange(_ session: ConnectivitySession)

  func session(
    _ session: ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping ConnectivityHandler
  )

  func session(
    _ session: ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: Error?
  )
}
