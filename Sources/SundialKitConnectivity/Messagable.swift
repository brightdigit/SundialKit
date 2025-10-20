//
//  Messagable.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
public protocol Messagable {
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
