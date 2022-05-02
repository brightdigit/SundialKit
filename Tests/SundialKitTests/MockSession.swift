import SundialKit

internal class MockSession: WCSessionable {
  internal var lastMessageSent: WCMessage?
  internal var lastAppContext: WCMessage?
  // swiftlint:disable:next implicitly_unwrapped_optional
  internal var nextReplyResult: Result<WCMessage, Error>!
  internal var nextApplicationContextError: Error?
  internal var isPaired = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  internal var delegate: WCSessionableDelegate?

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

  internal func updateApplicationContext(_ context: WCMessage) throws {
    if let nextApplicationContextError = nextApplicationContextError {
      throw nextApplicationContextError
    }
    lastAppContext = context
    delegate?.session(self, didReceiveApplicationContext: context, error: nil)
  }

  internal func sendMessage(
    _ message: WCMessage,
    _ replyHandler: @escaping (Result<WCMessage, Error>) -> Void
  ) {
    lastMessageSent = message
    replyHandler(nextReplyResult)
  }

  internal func receiveMessage(
    _ message: WCMessage,
    withReplyHandler replyHandler: @escaping WCMessageHandler
  ) {
    delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
  }
}
