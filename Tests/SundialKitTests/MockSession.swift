@testable import SundialKitConnectivity
@testable import SundialKitCore

internal final class MockSession: ConnectivitySession, @unchecked Sendable {
  internal var lastMessageSent: ConnectivityMessage?
  internal var lastAppContext: ConnectivityMessage?
  // swiftlint:disable:next implicitly_unwrapped_optional
  internal var nextReplyResult: Result<ConnectivityMessage, Error>!
  internal var nextApplicationContextError: Error?
  internal var isPaired = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  internal var delegate: ConnectivitySessionDelegate?

  internal var isReachable = false {
    didSet {
      delegate?.sessionReachabilityDidChange(self)
    }
  }

  internal var isPairedAppInstalled = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  internal var activationState: ActivationState = .notActivated {
    didSet {
      switch activationState {
      case .activated:
        delegate?.session(self, activationDidCompleteWith: activationState, error: nil)

      case .inactive:
        delegate?.sessionDidBecomeInactive(self)

      case .notActivated:
        delegate?.sessionDidDeactivate(self)
      }
    }
  }

  internal func activate() throws {
    activationState = .activated
  }

  internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
    if let nextApplicationContextError = nextApplicationContextError {
      throw nextApplicationContextError
    }
    lastAppContext = context
    delegate?.session(self, didReceiveApplicationContext: context, error: nil)
  }

  internal func sendMessage(
    _ message: ConnectivityMessage,
    _ replyHandler: @escaping (Result<ConnectivityMessage, Error>) -> Void
  ) {
    lastMessageSent = message
    replyHandler(nextReplyResult)
  }

  internal func receiveMessage(
    _ message: ConnectivityMessage,
    withReplyHandler replyHandler: @escaping ConnectivityHandler
  ) {
    delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
  }
}
