//
//  ConnectivityMessage.swift
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

/// A type alias for messages exchanged via WatchConnectivity.
///
/// Represents the dictionary-based message format required by WatchConnectivity.
/// Messages must contain only property list types (String, Number, Date, Data, Array, Dictionary).
///
/// ## Valid Value Types
///
/// Only the following Sendable types are valid as dictionary values:
/// - `String`
/// - `Int`, `Double`, `Float`, and other numeric types
/// - `Bool`
/// - `Date`
/// - `Data`
/// - `Array` containing valid types
/// - `Dictionary` containing valid types
///
/// ## Example
///
/// ```swift
/// // Valid messages
/// let message: ConnectivityMessage = [
///   "command": "updateColor",
///   "red": 1.0,
///   "green": 0.5,
///   "blue": 0.0,
///   "timestamp": Date()
/// ]
///
/// // Invalid - cannot contain non-property-list types
/// let invalid: ConnectivityMessage = [
///   "view": UIView()  // Error: UIView is not a property list type
/// ]
/// ```
///
/// > Important: While the type system enforces `Sendable`,
/// it cannot enforce property list types at compile time.
/// > Using invalid types will result in runtime errors when sending messages.
public typealias ConnectivityMessage = [String: any Sendable]

// swift-format-ignore: NeverForceUnwrap
extension Dictionary where Key == String, Value == any Sendable {
  /// Creates a ConnectivityMessage by force casting from `[String: Any]`.
  ///
  /// This initializer consolidates force casting logic into a single location,
  /// making it easier to handle WatchConnectivity APIs that return `[String: Any]`.
  ///
  /// - Parameter dictionary: The dictionary to convert. All values must actually
  ///   conform to `Sendable`, though the type system doesn't enforce this.
  ///
  /// - Warning: This initializer force casts the values to `any Sendable`.
  ///   Use only when you're certain all values conform to `Sendable`,
  ///   such as when receiving messages from WatchConnectivity APIs.
  ///
  /// ## Example
  ///
  /// ```swift
  /// // From WatchConnectivity delegate method
  /// func session(
  ///   _ session: WCSession,
  ///   didReceiveMessage message: [String: Any]
  /// ) {
  ///   let connectivityMessage = ConnectivityMessage(forceCasting: message)
  ///   // Use connectivityMessage safely
  /// }
  /// ```
  public init(forceCasting dictionary: [String: Any]) {
    // swiftlint:disable:next force_cast
    self = dictionary.mapValues { $0 as! any Sendable }
  }
}
