//
//  SerializationErrorTests.swift
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
import Testing

@testable import SundialKitCore

@Suite("SerializationError Tests")
struct SerializationErrorTests {
  // MARK: - Static Property Tests

  @Test("Invalid message format can be created")
  func invalidMessageFormatProperty() {
    let error = SerializationError.invalidMessageFormat
    #expect(error.kind == .invalidMessageFormat)
  }

  @Test("Invalid data can be created")
  func invalidDataProperty() {
    let error = SerializationError.invalidData
    #expect(error.kind == .invalidData)
  }

  @Test("Corrupted data can be created")
  func corruptedDataProperty() {
    let error = SerializationError.corruptedData
    #expect(error.kind == .corruptedData)
  }

  @Test("Missing type key can be created")
  func missingTypeKeyProperty() {
    let error = SerializationError.missingTypeKey
    #expect(error.kind == .missingTypeKey)
  }

  @Test("Missing binary data can be created")
  func missingBinaryDataProperty() {
    let error = SerializationError.missingBinaryData
    #expect(error.kind == .missingBinaryData)
  }

  @Test("Invalid data size can be created")
  func invalidDataSizeProperty() {
    let error = SerializationError.invalidDataSize
    #expect(error.kind == .invalidDataSize)
  }

  @Test("Invalid format can be created")
  func invalidFormatProperty() {
    let error = SerializationError.invalidFormat
    #expect(error.kind == .invalidFormat)
  }

  @Test("Invalid type key can be created")
  func invalidTypeKeyProperty() {
    let error = SerializationError.invalidTypeKey
    #expect(error.kind == .invalidTypeKey)
  }

  // MARK: - Factory Method Tests

  @Test("Encoding failed can be created with reason")
  func encodingFailedFactory() {
    let reason = "Circular reference detected"
    let error = SerializationError.encodingFailed(reason)

    #expect(error.kind == .encodingFailed)
    #expect(error.context.reason == reason)
  }

  @Test("Unsupported type can be created with type name")
  func unsupportedTypeFactory() {
    let typeName = "CustomClass"
    let error = SerializationError.unsupportedType(typeName)

    #expect(error.kind == .unsupportedType)
    #expect(error.context.type == typeName)
  }

  @Test("Decoding failed can be created with reason")
  func decodingFailedFactory() {
    let reason = "Invalid JSON structure"
    let error = SerializationError.decodingFailed(reason)

    #expect(error.kind == .decodingFailed)
    #expect(error.context.reason == reason)
  }

  @Test("Missing required key can be created with key name")
  func missingRequiredKeyFactory() {
    let key = "userId"
    let error = SerializationError.missingRequiredKey(key)

    #expect(error.kind == .missingRequiredKey)
    #expect(error.context.key == key)
  }

  @Test("Type mismatch can be created with details")
  func typeMismatchFactory() {
    let key = "age"
    let expected = "Int"
    let actual = "String"
    let error = SerializationError.typeMismatch(key: key, expected: expected, actual: actual)

    #expect(error.kind == .typeMismatch)
    #expect(error.context.key == key)
    #expect(error.context.expected == expected)
    #expect(error.context.actual == actual)
  }

  @Test("Unknown message type can be created with type")
  func unknownMessageTypeFactory() {
    let typeName = "UnknownMessage"
    let error = SerializationError.unknownMessageType(typeName)

    #expect(error.kind == .unknownMessageType)
    #expect(error.context.type == typeName)
  }

  @Test("Missing field can be created with field name")
  func missingFieldFactory() {
    let field = "timestamp"
    let error = SerializationError.missingField(field)

    #expect(error.kind == .missingField)
    #expect(error.context.field == field)
  }

  @Test("Not binary messagable can be created with type")
  func notBinaryMessagableFactory() {
    let typeName = "RegularMessage"
    let error = SerializationError.notBinaryMessagable(typeName)

    #expect(error.kind == .notBinaryMessagable)
    #expect(error.context.type == typeName)
  }

  // MARK: - ErrorContext Tests

  @Test("ErrorContext can be created with all parameters")
  func errorContextFullInitialization() {
    let context = SerializationError.ErrorContext(
      reason: "Test reason",
      type: "TestType",
      key: "testKey",
      expected: "ExpectedValue",
      actual: "ActualValue",
      field: "testField"
    )

    #expect(context.reason == "Test reason")
    #expect(context.type == "TestType")
    #expect(context.key == "testKey")
    #expect(context.expected == "ExpectedValue")
    #expect(context.actual == "ActualValue")
    #expect(context.field == "testField")
  }

  @Test("ErrorContext can be created with partial parameters")
  func errorContextPartialInitialization() {
    let context = SerializationError.ErrorContext(
      reason: "Partial reason",
      type: nil,
      key: "someKey"
    )

    #expect(context.reason == "Partial reason")
    #expect(context.type == nil)
    #expect(context.key == "someKey")
    #expect(context.expected == nil)
    #expect(context.actual == nil)
    #expect(context.field == nil)
  }

  // MARK: - LocalizedError Tests

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
        == "The message contains types that are not supported by the serialization format."
    )
    #expect(
      error.recoverySuggestion
        == "Convert custom types to property list types (String, Number, Date, Data, Array, Dictionary) before encoding."
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
        == "Ensure the message type conforms to BinaryMessagable protocol, or use dictionary transport instead of binary."
    )
  }

  // MARK: - All ErrorKind Cases Have Localization

  @Test("All ErrorKind cases have complete localization")
  func allErrorKindsHaveLocalization() {
    // Create one error for each ErrorKind
    let errors: [SerializationError] = [
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

    for error in errors {
      #expect(error.errorDescription != nil, "Missing errorDescription for \(error.kind)")
      #expect(error.failureReason != nil, "Missing failureReason for \(error.kind)")
      #expect(error.recoverySuggestion != nil, "Missing recoverySuggestion for \(error.kind)")

      #expect(!error.errorDescription!.isEmpty, "Empty errorDescription for \(error.kind)")
      #expect(!error.failureReason!.isEmpty, "Empty failureReason for \(error.kind)")
      #expect(!error.recoverySuggestion!.isEmpty, "Empty recoverySuggestion for \(error.kind)")
    }
  }

  // MARK: - Error Throwing Tests

  @Test("SerializationError can be thrown and caught")
  func errorThrowing() throws {
    func throwError() throws {
      throw SerializationError.invalidData
    }

    #expect(throws: SerializationError.self) {
      try throwError()
    }
  }

  @Test("Specific error kind can be checked when caught")
  func errorKindChecking() {
    func throwDecodingError() throws {
      throw SerializationError.decodingFailed("Parse error")
    }

    do {
      try throwDecodingError()
      Issue.record("Expected error to be thrown")
    } catch let error as SerializationError {
      #expect(error.kind == .decodingFailed)
      #expect(error.context.reason == "Parse error")
    } catch {
      Issue.record("Caught unexpected error: \(error)")
    }
  }
}
