public protocol WCSessionable: AnyObject {
  var delegate: WCSessionableDelegate? { get set }
  var isReachable: Bool { get }

  #if os(iOS)
    var isPaired: Bool { get }
  #endif
  var isPairedAppInstalled: Bool { get }
  var activationState: ActivationState { get }

  func activate() throws
  func updateApplicationContext(_ context: WCMessage) throws
  func sendMessage(
    _ message: WCMessage,
    _ completion: @escaping (Result<WCMessage, Error>) -> Void
  )
}
