public struct MessageDecoder {
  public init(messagableTypes: [Messagable.Type]) {
    self.messagableTypes = Dictionary(uniqueKeysWithValues: messagableTypes.map {
      ($0.key, $0)
    })
  }

  private let messagableTypes: [String: Messagable.Type]

  public func decode(_ message: ConnectivityMessage) -> Messagable? {
    guard let typeKey = message[MessagableKeys.typeKey] as? String else {
      return nil
    }

    guard let type = messagableTypes[typeKey] else {
      return nil
    }

    return type.init(from: message[MessagableKeys.parametersKey] as? [String: Any])
  }
}
