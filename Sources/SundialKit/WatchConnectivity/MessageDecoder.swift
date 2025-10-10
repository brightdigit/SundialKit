//
//  MessageDecoder.swift
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
    self.messagableTypes = Dictionary(
      uniqueKeysWithValues: messagableTypes.map {
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
