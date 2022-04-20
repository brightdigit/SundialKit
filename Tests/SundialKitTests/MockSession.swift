import SundialKit

public class MockSession: WCSessionable {
  var lastMessageSent: WCMessage?
  var lastAppContext: WCMessage?
  var nextReplyResult: Result<WCMessage, Error>!
  var nextApplicationContextError: Error?
  public var isPaired = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  public var delegate: WCSessionableDelegate?

  public func activate() throws {
    activationState = .activated
  }

  public var isReachable = false {
    didSet {
      delegate?.sessionReachabilityDidChange(self)
    }
  }

  public var isPairedAppInstalled = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  public var activationState: ActivationState = .notActivated {
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

  public func updateApplicationContext(_ context: WCMessage) throws {
    if let nextApplicationContextError = nextApplicationContextError {
      throw nextApplicationContextError
    }
    lastAppContext = context
    delegate?.session(self, didReceiveApplicationContext: context, error: nil)
  }

  public func sendMessage(_ message: WCMessage,
                          _ replyHandler: @escaping (Result<WCMessage, Error>) -> Void) {
    lastMessageSent = message
    replyHandler(nextReplyResult)
  }

  func receiveMessage(_ message: WCMessage,
                      withReplyHandler replyHandler: @escaping WCMessageHandler) {
    delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
  }
}
