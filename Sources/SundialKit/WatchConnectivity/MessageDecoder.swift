public struct MessageDecoder {
  let messagableTypes: [String: Messagable.Type]

  func decode(_ message: ConnectivityMessage) -> Messagable? {
    guard let typeKey = message[MessagableKeys.typeKey] as? String else {
      return nil
    }

    guard let type = messagableTypes[typeKey] else {
      return nil
    }

    return type.init(from: message[MessagableKeys.parametersKey] as? [String: Any])
  }
}
