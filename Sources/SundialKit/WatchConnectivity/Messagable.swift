/// An object which can be decoded by a ``MessageDecoder`` from a ``ConnectivityMessage``.
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
public protocol Messagable {
  /// The unique key or type name to use for decoding.
  static var key: String { get }

  /// Create the object based on the `Dictionary<String, Any>`.
  /// - Parameter parameters: The parameters value.
  init?(from parameters: [String: Any]?)

  /// The parameters of the `Messagable` object.
  /// - Returns: The parameters of the `Messagable` object.
  func parameters() -> [String: Any]
}

public extension Messagable {
  /// Converts the object into a usable `ConnectivityMessage` for
  /// `WatchConnectivity`
  /// - Returns: `ConnectivityMessage` i.e. `[String:Any]` for sending.
  func message() -> ConnectivityMessage {
    [
      MessagableKeys.typeKey: Self.key,
      MessagableKeys.parametersKey: parameters()
    ]
  }
}
