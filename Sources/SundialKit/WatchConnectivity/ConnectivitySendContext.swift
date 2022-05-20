/// Result from sending a message
public enum ConnectivitySendContext {
  /// Sent via application context
  case applicationContext
  /// Sent via message with reply received
  case reply(ConnectivityMessage)
  /// Failure
  case failure(Error)
}

extension ConnectivitySendContext {
  // swiftlint:disable:next explicit_acl
  init(_ result: Result<ConnectivityMessage, Error>) {
    switch result {
    case let .success(message):
      self = .reply(message)

    case let .failure(error):
      self = .failure(error)
    }
  }
}
