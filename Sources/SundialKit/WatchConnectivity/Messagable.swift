public protocol Messagable {
  static var key: String { get }
  func parameters() -> [String: Any]
  init?(from parameters: [String: Any]?)
}

public extension Messagable {
  func message() -> ConnectivityMessage {
    [
      MessagableKeys.typeKey: Self.key,
      MessagableKeys.parametersKey: parameters()
    ]
  }
}
