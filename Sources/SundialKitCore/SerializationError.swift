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
public struct SerializationError: Error, Sendable {
  /// The kind of serialization error.
  public let kind: ErrorKind

  /// Additional context information for the error.
  public let context: ErrorContext

  /// The specific type of serialization error.
  public enum ErrorKind: Sendable {
    case encodingFailed
    case unsupportedType
    case invalidMessageFormat
    case decodingFailed
    case missingRequiredKey
    case typeMismatch
    case invalidData
    case corruptedData
    case missingTypeKey
    case missingBinaryData
    case unknownMessageType
    case missingField
    case invalidDataSize
    case invalidFormat
    case invalidTypeKey
    case notBinaryMessagable
  }

  /// Context data associated with the error.
  public struct ErrorContext: Sendable {
    public let reason: String?
    public let type: String?
    public let key: String?
    public let expected: String?
    public let actual: String?
    public let field: String?

    public init(
      reason: String? = nil,
      type: String? = nil,
      key: String? = nil,
      expected: String? = nil,
      actual: String? = nil,
      field: String? = nil
    ) {
      self.reason = reason
      self.type = type
      self.key = key
      self.expected = expected
      self.actual = actual
      self.field = field
    }
  }

  private init(kind: ErrorKind, context: ErrorContext) {
    self.kind = kind
    self.context = context
  }

  // MARK: - Encoding Errors

  /// Failed to encode a message for transmission.
  ///
  /// - Parameter reason: A description of why encoding failed.
  public static func encodingFailed(_ reason: String) -> SerializationError {
    SerializationError(kind: .encodingFailed, context: ErrorContext(reason: reason))
  }

  /// The message contains a type that cannot be serialized.
  ///
  /// WatchConnectivity requires all message data to be property list types.
  ///
  /// - Parameter type: The name of the unsupported type.
  public static func unsupportedType(_ type: String) -> SerializationError {
    SerializationError(kind: .unsupportedType, context: ErrorContext(type: type))
  }

  /// The message format is invalid for serialization.
  ///
  /// The message structure does not conform to expected format requirements.
  public static var invalidMessageFormat: SerializationError {
    SerializationError(kind: .invalidMessageFormat, context: ErrorContext())
  }

  // MARK: - Decoding Errors

  /// Failed to decode a received message.
  ///
  /// - Parameter reason: A description of why decoding failed.
  public static func decodingFailed(_ reason: String) -> SerializationError {
    SerializationError(kind: .decodingFailed, context: ErrorContext(reason: reason))
  }

  /// A required key is missing from the message dictionary.
  ///
  /// - Parameter key: The name of the missing key.
  public static func missingRequiredKey(_ key: String) -> SerializationError {
    SerializationError(kind: .missingRequiredKey, context: ErrorContext(key: key))
  }

  /// The value for a key has an unexpected type.
  ///
  /// - Parameters:
  ///   - key: The dictionary key with the type mismatch.
  ///   - expected: The expected type name.
  ///   - actual: The actual type found.
  public static func typeMismatch(key: String, expected: String, actual: String)
    -> SerializationError
  {
    SerializationError(
      kind: .typeMismatch,
      context: ErrorContext(key: key, expected: expected, actual: actual)
    )
  }

  // MARK: - Data Errors

  /// The provided data is invalid or cannot be processed.
  ///
  /// The data format is unrecognized or does not match expected structure.
  public static var invalidData: SerializationError {
    SerializationError(kind: .invalidData, context: ErrorContext())
  }

  /// The data appears to be corrupted or incomplete.
  ///
  /// The data may have been truncated during transmission or storage.
  public static var corruptedData: SerializationError {
    SerializationError(kind: .corruptedData, context: ErrorContext())
  }

  // MARK: - Binary Messaging Errors

  /// The message type key is missing from the connectivity message.
  ///
  /// All messages must include a type discriminator for proper routing.
  public static var missingTypeKey: SerializationError {
    SerializationError(kind: .missingTypeKey, context: ErrorContext())
  }

  /// Binary data is missing from a binary message.
  ///
  /// BinaryMessagable types require binary data in the message parameters.
  public static var missingBinaryData: SerializationError {
    SerializationError(kind: .missingBinaryData, context: ErrorContext())
  }

  /// The specified message type is not registered with the decoder.
  ///
  /// - Parameter type: The unknown message type key.
  public static func unknownMessageType(_ type: String) -> SerializationError {
    SerializationError(kind: .unknownMessageType, context: ErrorContext(type: type))
  }

  /// A required field is missing from the message parameters.
  ///
  /// - Parameter field: The name of the missing field.
  public static func missingField(_ field: String) -> SerializationError {
    SerializationError(kind: .missingField, context: ErrorContext(field: field))
  }

  /// The binary data size is invalid for the expected format.
  ///
  /// Binary formats often have fixed or minimum size requirements.
  public static var invalidDataSize: SerializationError {
    SerializationError(kind: .invalidDataSize, context: ErrorContext())
  }

  /// The binary message format is invalid.
  ///
  /// The binary framing or structure does not match expected format.
  public static var invalidFormat: SerializationError {
    SerializationError(kind: .invalidFormat, context: ErrorContext())
  }

  /// The type key in the binary message footer is invalid.
  ///
  /// The type key must be valid UTF-8 encoded text.
  public static var invalidTypeKey: SerializationError {
    SerializationError(kind: .invalidTypeKey, context: ErrorContext())
  }

  /// The message type is not a BinaryMessagable type.
  ///
  /// Attempted to decode binary data but the registered type does not conform to BinaryMessagable.
  ///
  /// - Parameter type: The type key that is not BinaryMessagable.
  public static func notBinaryMessagable(_ type: String) -> SerializationError {
    SerializationError(kind: .notBinaryMessagable, context: ErrorContext(type: type))
  }
}

// MARK: - LocalizedError Conformance

extension SerializationError {
  /// Internal structure to hold localized error information.
  private struct ErrorInfo {
    let descriptionTemplate: String
    let reason: String
    let suggestion: String
  }

  /// Dictionary mapping error kinds to their localized information.
  private static let errorInfoMap: [ErrorKind: ErrorInfo] = [
    .encodingFailed: ErrorInfo(
      descriptionTemplate: "Failed to encode message: %@",
      reason: "The message could not be converted to a transmittable format.",
      suggestion: "Ensure all message data uses supported types and check for circular references."
    ),
    .unsupportedType: ErrorInfo(
      descriptionTemplate: "Unsupported type '%@' in message data.",
      reason: "The message contains types that are not supported by the serialization format.",
      suggestion: """
        Convert custom types to property list types \
        (String, Number, Date, Data, Array, Dictionary) before encoding.
        """
    ),
    .invalidMessageFormat: ErrorInfo(
      descriptionTemplate: "Invalid message format for serialization.",
      reason: "The message structure does not conform to required format.",
      suggestion: "Review message structure and ensure it conforms to the expected format."
    ),
    .decodingFailed: ErrorInfo(
      descriptionTemplate: "Failed to decode message: %@",
      reason: "The received message could not be parsed into the expected format.",
      suggestion: "Verify the message was encoded correctly and check for version compatibility."
    ),
    .missingRequiredKey: ErrorInfo(
      descriptionTemplate: "Required key '%@' is missing from message.",
      reason: "A required field is not present in the message.",
      suggestion: "Ensure the sender includes all required fields in the message."
    ),
    .typeMismatch: ErrorInfo(
      descriptionTemplate: "Type mismatch for key '%@': expected %@, got %@.",
      reason: "A field has a different type than expected.",
      suggestion:
        "Verify the message format matches the expected schema and check for type conversion issues."
    ),
    .invalidData: ErrorInfo(
      descriptionTemplate: "The provided data is invalid.",
      reason: "The data format is unrecognized or malformed.",
      suggestion: "Check that the data source is providing data in the expected format."
    ),
    .corruptedData: ErrorInfo(
      descriptionTemplate: "The data appears to be corrupted.",
      reason: "The data may have been damaged during transmission or storage.",
      suggestion: "Verify data integrity and consider requesting a fresh copy of the data."
    ),
    .missingTypeKey: ErrorInfo(
      descriptionTemplate: "Message type key is missing.",
      reason: "The message does not include a type discriminator for routing.",
      suggestion: "Ensure all messages include the '__type' key for proper routing."
    ),
    .missingBinaryData: ErrorInfo(
      descriptionTemplate: "Binary data is missing from binary message.",
      reason: "The binary message parameters do not include required binary data.",
      suggestion: "Ensure binary messages include the '__data' key with valid Data content."
    ),
    .unknownMessageType: ErrorInfo(
      descriptionTemplate: "Unknown message type '%@'.",
      reason: "The message type is not recognized by the decoder.",
      suggestion: "Register the message type with MessageDecoder or verify the type key is correct."
    ),
    .missingField: ErrorInfo(
      descriptionTemplate: "Required field '%@' is missing.",
      reason: "A required parameter field is not present in the message.",
      suggestion: "Ensure the sender includes all required parameter fields in the message."
    ),
    .invalidDataSize: ErrorInfo(
      descriptionTemplate: "Binary data size is invalid for expected format.",
      reason: "The binary data does not meet size requirements for the format.",
      suggestion: "Verify the binary format requirements and ensure data meets size constraints."
    ),
    .invalidFormat: ErrorInfo(
      descriptionTemplate: "Binary message format is invalid.",
      reason: "The binary message framing or structure is malformed.",
      suggestion: "Check the binary framing format and ensure type footer is correctly formatted."
    ),
    .invalidTypeKey: ErrorInfo(
      descriptionTemplate: "The type key in the binary message footer is invalid.",
      reason: "The type key footer contains invalid UTF-8 data.",
      suggestion: "Ensure the type key is valid UTF-8 text and the binary footer is not corrupted."
    ),
    .notBinaryMessagable: ErrorInfo(
      descriptionTemplate: "Message type '%@' is not a BinaryMessagable type.",
      reason: "The type cannot decode binary data because it does not conform to BinaryMessagable.",
      suggestion: """
        Ensure the message type conforms to BinaryMessagable protocol, \
        or use dictionary transport instead of binary.
        """
    ),
  ]

  /// Returns the error info from the dictionary.
  private var errorInfo: ErrorInfo {
    Self.errorInfoMap[kind]!
  }
}

extension SerializationError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    let template = errorInfo.descriptionTemplate
    switch kind {
    case .encodingFailed:
      return String(format: template, context.reason ?? "")
    case .unsupportedType:
      return String(format: template, context.type ?? "")
    case .invalidMessageFormat:
      return template
    case .decodingFailed:
      return String(format: template, context.reason ?? "")
    case .missingRequiredKey:
      return String(format: template, context.key ?? "")
    case .typeMismatch:
      return String(
        format: template, context.key ?? "", context.expected ?? "", context.actual ?? "")
    case .invalidData:
      return template
    case .corruptedData:
      return template
    case .missingTypeKey:
      return template
    case .missingBinaryData:
      return template
    case .unknownMessageType:
      return String(format: template, context.type ?? "")
    case .missingField:
      return String(format: template, context.field ?? "")
    case .invalidDataSize:
      return template
    case .invalidFormat:
      return template
    case .invalidTypeKey:
      return template
    case .notBinaryMessagable:
      return String(format: template, context.type ?? "")
    }
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    errorInfo.reason
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    errorInfo.suggestion
  }
}
