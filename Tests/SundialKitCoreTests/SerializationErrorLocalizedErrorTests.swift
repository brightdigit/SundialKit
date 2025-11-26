//
// SerializationErrorLocalizedErrorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

@Suite("SerializationError LocalizedError Tests")
struct SerializationErrorLocalizedErrorTests {
  // Create one error for each ErrorKind
  static let errors: [SerializationError] = [
    .encodingFailed("test"),
    .unsupportedType("test"),
    .invalidMessageFormat,
    .decodingFailed("test"),
    .missingRequiredKey("test"),
    .typeMismatch(key: "key", expected: "exp", actual: "act"),
    .invalidData,
    .corruptedData,
    .missingTypeKey,
    .missingBinaryData,
    .unknownMessageType("test"),
    .missingField("test"),
    .invalidDataSize,
    .invalidFormat,
    .invalidTypeKey,
    .notBinaryMessagable("test"),
  ]

  @Test("Encoding failed has proper localization")
  func encodingFailedLocalization() {
    let reason = "Object too large"
    let error = SerializationError.encodingFailed(reason)

    #expect(error.errorDescription == "Failed to encode message: \(reason)")
    #expect(
      error.failureReason == "The message could not be converted to a transmittable format."
    )
    #expect(
      error.recoverySuggestion
        == "Ensure all message data uses supported types and check for circular references."
    )
  }

  @Test("Unsupported type has proper localization")
  func unsupportedTypeLocalization() {
    let typeName = "UIImage"
    let error = SerializationError.unsupportedType(typeName)

    #expect(error.errorDescription == "Unsupported type '\(typeName)' in message data.")
    #expect(
      error.failureReason
        == "The message contains types that are not supported" + " by the serialization format."
    )
    #expect(
      error.recoverySuggestion
        == "Convert custom types to property list types (String, Number,"
        + " Date, Data, Array, Dictionary) before encoding."
    )
  }

  @Test("Invalid message format has proper localization")
  func invalidMessageFormatLocalization() {
    let error = SerializationError.invalidMessageFormat

    #expect(error.errorDescription == "Invalid message format for serialization.")
    #expect(error.failureReason == "The message structure does not conform to required format.")
    #expect(
      error.recoverySuggestion
        == "Review message structure and ensure it conforms to the expected format."
    )
  }

  @Test("Decoding failed has proper localization")
  func decodingFailedLocalization() {
    let reason = "Unexpected end of data"
    let error = SerializationError.decodingFailed(reason)

    #expect(error.errorDescription == "Failed to decode message: \(reason)")
    #expect(
      error.failureReason
        == "The received message could not be parsed into the expected format."
    )
    #expect(
      error.recoverySuggestion
        == "Verify the message was encoded correctly and check for version compatibility."
    )
  }

  @Test("Missing required key has proper localization")
  func missingRequiredKeyLocalization() {
    let key = "authToken"
    let error = SerializationError.missingRequiredKey(key)

    #expect(error.errorDescription == "Required key '\(key)' is missing from message.")
    #expect(error.failureReason == "A required field is not present in the message.")
    #expect(
      error.recoverySuggestion == "Ensure the sender includes all required fields in the message."
    )
  }

  @Test("Type mismatch has proper localization")
  func typeMismatchLocalization() {
    let key = "count"
    let expected = "Int"
    let actual = "String"
    let error = SerializationError.typeMismatch(key: key, expected: expected, actual: actual)

    #expect(
      error.errorDescription
        == "Type mismatch for key '\(key)': expected \(expected), got \(actual)."
    )
    #expect(error.failureReason == "A field has a different type than expected.")
    #expect(
      error.recoverySuggestion
        == "Verify the message format matches the expected schema and check for type conversion issues."
    )
  }

  @Test("Invalid data has proper localization")
  func invalidDataLocalization() {
    let error = SerializationError.invalidData

    #expect(error.errorDescription == "The provided data is invalid.")
    #expect(error.failureReason == "The data format is unrecognized or malformed.")
    #expect(
      error.recoverySuggestion
        == "Check that the data source is providing data in the expected format."
    )
  }

  @Test("Corrupted data has proper localization")
  func corruptedDataLocalization() {
    let error = SerializationError.corruptedData

    #expect(error.errorDescription == "The data appears to be corrupted.")
    #expect(
      error.failureReason == "The data may have been damaged during transmission or storage."
    )
    #expect(
      error.recoverySuggestion
        == "Verify data integrity and consider requesting a fresh copy of the data."
    )
  }

  @Test("Missing type key has proper localization")
  func missingTypeKeyLocalization() {
    let error = SerializationError.missingTypeKey

    #expect(error.errorDescription == "Message type key is missing.")
    #expect(
      error.failureReason == "The message does not include a type discriminator for routing."
    )
    #expect(
      error.recoverySuggestion
        == "Ensure all messages include the '__type' key for proper routing."
    )
  }

  @Test("Missing binary data has proper localization")
  func missingBinaryDataLocalization() {
    let error = SerializationError.missingBinaryData

    #expect(error.errorDescription == "Binary data is missing from binary message.")
    #expect(
      error.failureReason
        == "The binary message parameters do not include required binary data."
    )
    #expect(
      error.recoverySuggestion
        == "Ensure binary messages include the '__data' key with valid Data content."
    )
  }

  @Test("Unknown message type has proper localization")
  func unknownMessageTypeLocalization() {
    let typeName = "UnsupportedMessageType"
    let error = SerializationError.unknownMessageType(typeName)

    #expect(error.errorDescription == "Unknown message type '\(typeName)'.")
    #expect(error.failureReason == "The message type is not recognized by the decoder.")
    #expect(
      error.recoverySuggestion
        == "Register the message type with MessageDecoder or verify the type key is correct."
    )
  }

  @Test("Missing field has proper localization")
  func missingFieldLocalization() {
    let field = "payload"
    let error = SerializationError.missingField(field)

    #expect(error.errorDescription == "Required field '\(field)' is missing.")
    #expect(error.failureReason == "A required parameter field is not present in the message.")
    #expect(
      error.recoverySuggestion
        == "Ensure the sender includes all required parameter fields in the message."
    )
  }

  @Test("Invalid data size has proper localization")
  func invalidDataSizeLocalization() {
    let error = SerializationError.invalidDataSize

    #expect(error.errorDescription == "Binary data size is invalid for expected format.")
    #expect(
      error.failureReason == "The binary data does not meet size requirements for the format."
    )
    #expect(
      error.recoverySuggestion
        == "Verify the binary format requirements and ensure data meets size constraints."
    )
  }

  @Test("Invalid format has proper localization")
  func invalidFormatLocalization() {
    let error = SerializationError.invalidFormat

    #expect(error.errorDescription == "Binary message format is invalid.")
    #expect(error.failureReason == "The binary message framing or structure is malformed.")
    #expect(
      error.recoverySuggestion
        == "Check the binary framing format and ensure type footer is correctly formatted."
    )
  }

  @Test("Invalid type key has proper localization")
  func invalidTypeKeyLocalization() {
    let error = SerializationError.invalidTypeKey

    #expect(error.errorDescription == "The type key in the binary message footer is invalid.")
    #expect(error.failureReason == "The type key footer contains invalid UTF-8 data.")
    #expect(
      error.recoverySuggestion
        == "Ensure the type key is valid UTF-8 text and the binary footer is not corrupted."
    )
  }

  @Test("Not binary messagable has proper localization")
  func notBinaryMessagableLocalization() {
    let typeName = "SimpleMessage"
    let error = SerializationError.notBinaryMessagable(typeName)

    #expect(
      error.errorDescription == "Message type '\(typeName)' is not a BinaryMessagable type."
    )
    #expect(
      error.failureReason
        == "The type cannot decode binary data because it does not conform to BinaryMessagable."
    )
    #expect(
      error.recoverySuggestion
        // swiftlint:disable:next line_length
        == "Ensure the message type conforms to BinaryMessagable protocol, or use dictionary transport instead of binary."
    )
  }

  @Test("All ErrorKind cases have complete localization")
  func allErrorKindsHaveLocalization() {
    for error in Self.errors {
      #expect(error.errorDescription != nil, "Missing errorDescription for \(error.kind)")
      #expect(error.failureReason != nil, "Missing failureReason for \(error.kind)")
      #expect(error.recoverySuggestion != nil, "Missing recoverySuggestion for \(error.kind)")

      #expect(
        error.errorDescription?.isEmpty == false,
        "Empty errorDescription for \(error.kind)")
      #expect(
        error.failureReason?.isEmpty == false,
        "Empty failureReason for \(error.kind)")
      #expect(
        error.recoverySuggestion?.isEmpty == false,
        "Empty recoverySuggestion for \(error.kind)")
    }
  }
}
