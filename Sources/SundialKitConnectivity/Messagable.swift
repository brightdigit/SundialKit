//
// Messagable.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// An object which can be decoded by a ``MessageDecoder`` from a ``ConnectivityMessage``.
///
/// ```swift
/// struct Message: Messagable {
///   // key defaults to "Message" (type name)
///
///   enum Parameters: String {
///     case text
///   }
///
///   init(from parameters: [String: any Sendable]) throws {
///     guard let text = parameters[Parameters.text.rawValue] as? String else {
///       throw SerializationError.missingField(Parameters.text.rawValue)
///     }
///
///     self.text = text
///   }
///
///   func parameters() -> [String: any Sendable] {
///     return [
///       Parameters.text.rawValue: self.text
///     ]
///   }
///
///   let text: String
/// }
///
/// let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
/// let message = try messageDecoder.decode(connectivityMessage)
/// ```
public protocol Messagable: Sendable {
  /// The unique key or type name to use for decoding.
  /// Defaults to the type name if not explicitly provided.
  static var key: String { get }

  /// Create the object from parameters dictionary.
  /// - Parameter parameters: The parameters dictionary.
  /// - Throws: SerializationError if decoding fails.
  init(from parameters: [String: any Sendable]) throws

  /// The parameters of the `Messagable` object.
  /// - Returns: The parameters of the `Messagable` object.
  func parameters() -> [String: any Sendable]
}

// Default key implementation using type name
extension Messagable {
  /// Default implementation uses the type name as the key
  public static var key: String {
    String(describing: Self.self)
  }
}

extension Messagable {
  /// Converts the object into a usable `ConnectivityMessage` for
  /// `WatchConnectivity`
  /// - Returns: `ConnectivityMessage` i.e. `[String:Any]` for sending.
  public func message() -> ConnectivityMessage {
    [
      MessagableKeys.typeKey: Self.key,
      MessagableKeys.parametersKey: parameters(),
    ]
  }
}
