//
// SerializationError+LocalizedError.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation

// MARK: - LocalizedError Conformance

extension SerializationError {
  /// Internal structure to hold localized error information.
  internal struct ErrorInfo {
    internal let descriptionTemplate: String
    internal let reason: String
    internal let suggestion: String
  }

  /// Dictionary mapping error kinds to their localized information.
  internal static let errorInfoMap: [ErrorKind: ErrorInfo] = [
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
  internal var errorInfo: ErrorInfo {
    Self.errorInfoMap[kind]
      ?? ErrorInfo(
        descriptionTemplate: "Unknown serialization error",
        reason: "An unexpected serialization error occurred.",
        suggestion: "Please report this issue with error details."
      )
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
        format: template, context.key ?? "", context.expected ?? "", context.actual ?? ""
      )
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
