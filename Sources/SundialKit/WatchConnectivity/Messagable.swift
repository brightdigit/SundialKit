public protocol Messagable {
  static var key: String { get }
  init?(from parameters: [String: Any]?)
  func parameters() -> [String: Any]
}

public extension Messagable {
  func message() -> ConnectivityMessage {
    [
      MessagableKeys.typeKey: Self.key,
      MessagableKeys.parametersKey: parameters()
    ]
  }
}
