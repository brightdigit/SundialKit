//
//  SerializationErrorLocalizedErrorTests.swift
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
    let encodingFailedReason =
      "The message could not be converted to a transmittable format."
    #expect(error.failureReason == encodingFailedReason)
    #expect(
      error.recoverySuggestion
        == "Ensure all message data uses supported types"
        + " and check for circular references."
    )
  }

  @Test("Unsupported type has proper localization")
  func unsupportedTypeLocalization() {
    let typeName = "UIImage"
    let error = SerializationError.unsupportedType(typeName)

    #expect(error.errorDescription == "Unsupported type '\(typeName)' in message data.")
    let unsupportedTypeReason =
      "The message contains types that are not supported"
      + " by the serialization format."
    #expect(error.failureReason == unsupportedTypeReason)
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
    let invalidFormatReason =
      "The message structure does not conform to required format."
    #expect(error.failureReason == invalidFormatReason)
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
      error.recoverySuggestion
        == "Ensure the sender includes all required fields in the message."
    )
  }

  @Test("Type mismatch has proper localization")
  func typeMismatchLocalization() {
    let key = "count"
    let expected = "Int"
    let actual = "String"
    let error = SerializationError.typeMismatch(
      key: key, expected: expected, actual: actual
    )

    #expect(
      error.errorDescription
        == "Type mismatch for key '\(key)': expected \(expected), got \(actual)."
    )
    #expect(error.failureReason == "A field has a different type than expected.")
    #expect(
      error.recoverySuggestion
        == "Verify the message format matches the expected schema"
        + " and check for type conversion issues."
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
    let corruptedDataReason =
      "The data may have been damaged during transmission or storage."
    #expect(error.failureReason == corruptedDataReason)
    #expect(
      error.recoverySuggestion
        == "Verify data integrity and consider requesting a fresh copy of the data."
    )
  }
}
