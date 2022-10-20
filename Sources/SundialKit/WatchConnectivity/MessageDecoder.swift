/// Decodes a ``ConnectivityMessage`` based on provided ``Messagable`` types.
///
/// ```swift
/// struct Message : Messagable {
///   internal init(text: String) {
///     self.text = text
///   }
///
///   static let key: String = "_message"
///
///   enum Parameters : String {
///     case text
///   }
///
///   init?(from parameters: [String : Any]?) {
///     guard let text = parameters?[Parameters.text.rawValue] as? String else {
///       return nil
///     }
///
///     self.text = text
///   }
///
///   func parameters() -> [String : Any] {
///     return [
///       Parameters.text.rawValue : self.text
///     ]
///   }
///
///   let text : String
/// }
///
/// let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
/// ```
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
