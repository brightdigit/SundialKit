public enum WCSendMessageResult {
  case applicationContext
  case reply(WCMessage)
  case failure(Error)
  case noCompanion
}

extension WCSendMessageResult {
  init(_ result: Result<WCMessage, Error>) {
    switch result {
    case let .success(message):
      self = .reply(message)

    case let .failure(error):
      self = .failure(error)
    }
  }
}
