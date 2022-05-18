/// Result from sending a message
public enum WCSendMessageResult {
  /// Sent via application context
  case applicationContext
  /// Sent via message with reply received
  case reply(WCMessage)
  /// Failure
  case failure(Error)
}

extension WCSendMessageResult {
  // swiftlint:disable:next explicit_acl
  init(_ result: Result<WCMessage, Error>) {
    switch result {
    case let .success(message):
      self = .reply(message)

    case let .failure(error):
      self = .failure(error)
    }
  }
}
