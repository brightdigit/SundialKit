import Foundation

internal class NeverConnectivitySession: NSObject, ConnectivitySession {
  internal var delegate: ConnectivitySessionDelegate? {
    get {
      nil
    }
    // swiftlint:disable:next unused_setter_value
    set {}
  }

  internal var isReachable: Bool {
    false
  }

  internal var isPaired: Bool {
    false
  }

  internal var isPairedAppInstalled: Bool {
    false
  }

  internal var activationState: ActivationState {
    .notActivated
  }

  internal func activate() throws {
    throw SundialError.sessionNotSupported
  }

  internal func updateApplicationContext(_: ConnectivityMessage) throws {}

  internal func sendMessage(
    _: ConnectivityMessage,
    _: @escaping (Result<ConnectivityMessage, Error>) -> Void
  ) {}
}
