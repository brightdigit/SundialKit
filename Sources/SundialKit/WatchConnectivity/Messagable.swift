/// An object which can be decoded from a `ConnectivityMessage`
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
