internal protocol ConnectivitySession: AnyObject {
  var delegate: ConnectivitySessionDelegate? { get set }
  var isReachable: Bool { get }

  #if os(iOS)
    var isPaired: Bool { get }
  #endif
  var isPairedAppInstalled: Bool { get }
  var activationState: ActivationState { get }

  func activate() throws
  func updateApplicationContext(_ context: ConnectivityMessage) throws
  func sendMessage(
    _ message: ConnectivityMessage,
    _ completion: @escaping (Result<ConnectivityMessage, Error>) -> Void
  )
}
