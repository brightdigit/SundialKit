import SundialKit

public class MockSession: WCSessionable {
  var lastMessageSent: WCMessage?
  var lastAppContext: WCMessage?
  var nextReplyResult: Result<WCMessage, Error>!
  public var isPaired = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  public var delegate: WCSessionableDelegate?

  public func activate() throws {}

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
      delegate?.session(self, activationDidCompleteWith: activationState, error: nil)
    }
  }

  public func updateApplicationContext(_ context: WCMessage) throws {
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
