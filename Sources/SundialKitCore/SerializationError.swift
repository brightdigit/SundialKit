//
//  SerializationError.swift
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

public import Foundation

/// Errors that can occur during message serialization and deserialization.
///
/// `SerializationError` provides detailed information about failures when
/// encoding messages for transmission or decoding received messages in
/// connectivity operations.
///
/// All cases conform to `Error`, `Sendable`, and `LocalizedError` for
/// comprehensive error handling and reporting.
///
/// ## Topics
///
/// ### Encoding Errors
/// - ``encodingFailed(_:)``
/// - ``unsupportedType(_:)``
/// - ``invalidMessageFormat``
///
/// ### Decoding Errors
/// - ``decodingFailed(_:)``
/// - ``missingRequiredKey(_:)``
/// - ``typeMismatch(key:expected:actual:)``
///
/// ### Data Errors
/// - ``invalidData``
/// - ``corruptedData``
///
/// ## Example Usage
///
/// ```swift
/// struct UserMessage: Messagable {
///     let action: String
///     let timestamp: Date
///
///     init?(from message: ConnectivityMessage) {
///         guard let action = message["action"] as? String else {
///             throw SerializationError.missingRequiredKey("action")
///         }
///         guard let timestamp = message["timestamp"] as? Date else {
///             throw SerializationError.typeMismatch(
///                 key: "timestamp",
///                 expected: "Date",
///                 actual: type(of: message["timestamp"])
///             )
///         }
///         self.action = action
///         self.timestamp = timestamp
///     }
/// }
/// ```
public enum SerializationError: Error, Sendable {
  // MARK: - Encoding Errors

  /// Failed to encode a message for transmission.
  ///
  /// - Parameter reason: A description of why encoding failed.
  case encodingFailed(String)

  /// The message contains a type that cannot be serialized.
  ///
  /// WatchConnectivity requires all message data to be property list types.
  ///
  /// - Parameter type: The name of the unsupported type.
  case unsupportedType(String)

  /// The message format is invalid for serialization.
  ///
  /// The message structure does not conform to expected format requirements.
  case invalidMessageFormat

  // MARK: - Decoding Errors

  /// Failed to decode a received message.
  ///
  /// - Parameter reason: A description of why decoding failed.
  case decodingFailed(String)

  /// A required key is missing from the message dictionary.
  ///
  /// - Parameter key: The name of the missing key.
  case missingRequiredKey(String)

  /// The value for a key has an unexpected type.
  ///
  /// - Parameters:
  ///   - key: The dictionary key with the type mismatch.
  ///   - expected: The expected type name.
  ///   - actual: The actual type found.
  case typeMismatch(key: String, expected: String, actual: String)

  // MARK: - Data Errors

  /// The provided data is invalid or cannot be processed.
  ///
  /// The data format is unrecognized or does not match expected structure.
  case invalidData

  /// The data appears to be corrupted or incomplete.
  ///
  /// The data may have been truncated during transmission or storage.
  case corruptedData
}

// MARK: - LocalizedError Conformance

extension SerializationError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .encodingFailed(let reason):
      return "Failed to encode message: \(reason)"
    case .unsupportedType(let type):
      return "Unsupported type '\(type)' in message data."
    case .invalidMessageFormat:
      return "Invalid message format for serialization."
    case .decodingFailed(let reason):
      return "Failed to decode message: \(reason)"
    case .missingRequiredKey(let key):
      return "Required key '\(key)' is missing from message."
    case .typeMismatch(let key, let expected, let actual):
      return "Type mismatch for key '\(key)': expected \(expected), got \(actual)."
    case .invalidData:
      return "The provided data is invalid."
    case .corruptedData:
      return "The data appears to be corrupted."
    }
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    switch self {
    case .encodingFailed:
      return "The message could not be converted to a transmittable format."
    case .unsupportedType:
      return "The message contains types that are not supported by the serialization format."
    case .invalidMessageFormat:
      return "The message structure does not conform to required format."
    case .decodingFailed:
      return "The received message could not be parsed into the expected format."
    case .missingRequiredKey:
      return "A required field is not present in the message."
    case .typeMismatch:
      return "A field has a different type than expected."
    case .invalidData:
      return "The data format is unrecognized or malformed."
    case .corruptedData:
      return "The data may have been damaged during transmission or storage."
    }
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    switch self {
    case .encodingFailed:
      return "Ensure all message data uses supported types and check for circular references."
    case .unsupportedType:
      return """
        Convert custom types to property list types \
        (String, Number, Date, Data, Array, Dictionary) before encoding.
        """
    case .invalidMessageFormat:
      return "Review message structure and ensure it conforms to the expected format."
    case .decodingFailed:
      return "Verify the message was encoded correctly and check for version compatibility."
    case .missingRequiredKey:
      return "Ensure the sender includes all required fields in the message."
    case .typeMismatch:
      return
        "Verify the message format matches the expected schema and check for type conversion issues."
    case .invalidData:
      return "Check that the data source is providing data in the expected format."
    case .corruptedData:
      return "Verify data integrity and consider requesting a fresh copy of the data."
    }
  }
}
