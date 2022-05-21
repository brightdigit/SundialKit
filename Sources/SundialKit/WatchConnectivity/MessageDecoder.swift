/// Decodes a `ConnectivityMessage` based on provided `Messagable` types.
public struct MessageDecoder {
  private let messagableTypes: [String: Messagable.Type]

  /// Creates a `MessageDecoder` based on a list of `Messagable` types.
  /// - Parameter messagableTypes: A list of `Messagable` types.
  public init(messagableTypes: [Messagable.Type]) {
    self.messagableTypes = Dictionary(uniqueKeysWithValues: messagableTypes.map {
      ($0.key, $0)
    })
  }

  /// Decodes the `ConnectivityMessage` into a `Messagable` object.
  /// - Parameter message: The `ConnectivityMessage` or `[String : Any]` object.
  /// - Returns: The `Messagable`  object or nil if it couldn't be decoded.
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
