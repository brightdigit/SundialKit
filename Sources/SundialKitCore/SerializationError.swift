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

import Foundation

/// Errors that can occur during message serialization and deserialization.
///
/// Provides detailed information about failures when encoding messages for transmission
/// or decoding received messages in connectivity operations.
public struct SerializationError: Error, Sendable {
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
    /// Human-readable reason for the error.
    public let reason: String?
    /// The type involved in the error.
    public let type: String?
    /// The dictionary key involved in the error.
    public let key: String?
    /// The expected type or value.
    public let expected: String?
    /// The actual type or value encountered.
    public let actual: String?
    /// The specific field that caused the error.
    public let field: String?

    /// Creates error context with detailed information.
    ///
    /// - Parameters:
    ///   - reason: Human-readable reason for the error
    ///   - type: The type involved in the error
    ///   - key: The dictionary key involved in the error
    ///   - expected: The expected type or value
    ///   - actual: The actual type or value encountered
    ///   - field: The specific field that caused the error
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

  // MARK: - Type Properties

  /// The message format is invalid for serialization.
  public static var invalidMessageFormat: SerializationError {
    SerializationError(kind: .invalidMessageFormat, context: ErrorContext())
  }

  /// The provided data is invalid or cannot be processed.
  public static var invalidData: SerializationError {
    SerializationError(kind: .invalidData, context: ErrorContext())
  }

  /// The data appears to be corrupted or incomplete.
  public static var corruptedData: SerializationError {
    SerializationError(kind: .corruptedData, context: ErrorContext())
  }

  /// The message type key is missing from the connectivity message.
  public static var missingTypeKey: SerializationError {
    SerializationError(kind: .missingTypeKey, context: ErrorContext())
  }

  /// Binary data is missing from a binary message.
  public static var missingBinaryData: SerializationError {
    SerializationError(kind: .missingBinaryData, context: ErrorContext())
  }

  /// The binary data size is invalid for the expected format.
  public static var invalidDataSize: SerializationError {
    SerializationError(kind: .invalidDataSize, context: ErrorContext())
  }

  /// The binary message format is invalid.
  public static var invalidFormat: SerializationError {
    SerializationError(kind: .invalidFormat, context: ErrorContext())
  }

  /// The type key in the binary message footer is invalid.
  public static var invalidTypeKey: SerializationError {
    SerializationError(kind: .invalidTypeKey, context: ErrorContext())
  }

  // MARK: - Instance Properties

  /// The kind of serialization error.
  public let kind: ErrorKind

  /// Additional context information for the error.
  public let context: ErrorContext

  // MARK: - Initializers

  private init(kind: ErrorKind, context: ErrorContext) {
    self.kind = kind
    self.context = context
  }

  // MARK: - Type Methods

  // MARK: Encoding Errors

  /// Failed to encode a message for transmission.
  public static func encodingFailed(_ reason: String) -> SerializationError {
    SerializationError(kind: .encodingFailed, context: ErrorContext(reason: reason))
  }

  /// The message contains a type that cannot be serialized.
  public static func unsupportedType(_ type: String) -> SerializationError {
    SerializationError(kind: .unsupportedType, context: ErrorContext(type: type))
  }

  // MARK: Decoding Errors

  /// Failed to decode a received message.
  public static func decodingFailed(_ reason: String) -> SerializationError {
    SerializationError(kind: .decodingFailed, context: ErrorContext(reason: reason))
  }

  /// A required key is missing from the message dictionary.
  public static func missingRequiredKey(_ key: String) -> SerializationError {
    SerializationError(kind: .missingRequiredKey, context: ErrorContext(key: key))
  }

  /// The value for a key has an unexpected type.
  public static func typeMismatch(key: String, expected: String, actual: String)
    -> SerializationError
  {
    SerializationError(
      kind: .typeMismatch,
      context: ErrorContext(key: key, expected: expected, actual: actual)
    )
  }

  // MARK: Binary Messaging Errors

  /// The specified message type is not registered with the decoder.
  public static func unknownMessageType(_ type: String) -> SerializationError {
    SerializationError(kind: .unknownMessageType, context: ErrorContext(type: type))
  }

  /// A required field is missing from the message parameters.
  public static func missingField(_ field: String) -> SerializationError {
    SerializationError(kind: .missingField, context: ErrorContext(field: field))
  }

  /// The message type is not a BinaryMessagable type.
  public static func notBinaryMessagable(_ type: String) -> SerializationError {
    SerializationError(kind: .notBinaryMessagable, context: ErrorContext(type: type))
  }
}
