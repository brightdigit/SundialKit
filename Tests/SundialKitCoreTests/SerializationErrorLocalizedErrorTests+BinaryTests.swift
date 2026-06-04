//
//  SerializationErrorLocalizedErrorTests+BinaryTests.swift
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

extension SerializationErrorLocalizedErrorTests {
  @Test("Missing type key has proper localization")
  func missingTypeKeyLocalization() {
    let error = SerializationError.missingTypeKey

    #expect(error.errorDescription == "Message type key is missing.")
    let missingTypeKeyReason =
      "The message does not include a type discriminator for routing."
    #expect(error.failureReason == missingTypeKeyReason)
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
        == "Register the message type with MessageDecoder"
        + " or verify the type key is correct."
    )
  }

  @Test("Missing field has proper localization")
  func missingFieldLocalization() {
    let field = "payload"
    let error = SerializationError.missingField(field)

    #expect(error.errorDescription == "Required field '\(field)' is missing.")
    let missingFieldReason =
      "A required parameter field is not present in the message."
    #expect(error.failureReason == missingFieldReason)
    #expect(
      error.recoverySuggestion
        == "Ensure the sender includes all required parameter fields in the message."
    )
  }

  @Test("Invalid data size has proper localization")
  func invalidDataSizeLocalization() {
    let error = SerializationError.invalidDataSize

    #expect(error.errorDescription == "Binary data size is invalid for expected format.")
    let invalidDataSizeReason =
      "The binary data does not meet size requirements for the format."
    #expect(error.failureReason == invalidDataSizeReason)
    let invalidDataSizeSuggestion =
      "Verify the binary format requirements and ensure data meets size constraints."
    #expect(error.recoverySuggestion == invalidDataSizeSuggestion)
  }

  @Test("Invalid format has proper localization")
  func invalidFormatLocalization() {
    let error = SerializationError.invalidFormat

    #expect(error.errorDescription == "Binary message format is invalid.")
    let invalidFormatReason =
      "The binary message framing or structure is malformed."
    #expect(error.failureReason == invalidFormatReason)
    #expect(
      error.recoverySuggestion
        == "Check the binary framing format"
        + " and ensure type footer is correctly formatted."
    )
  }

  @Test("Invalid type key has proper localization")
  func invalidTypeKeyLocalization() {
    let error = SerializationError.invalidTypeKey

    let invalidTypeKeyDescription =
      "The type key in the binary message footer is invalid."
    #expect(error.errorDescription == invalidTypeKeyDescription)
    #expect(error.failureReason == "The type key footer contains invalid UTF-8 data.")
    #expect(
      error.recoverySuggestion
        == "Ensure the type key is valid UTF-8 text"
        + " and the binary footer is not corrupted."
    )
  }

  @Test("Not binary messagable has proper localization")
  func notBinaryMessagableLocalization() {
    let typeName = "SimpleMessage"
    let error = SerializationError.notBinaryMessagable(typeName)

    #expect(
      error.errorDescription
        == "Message type '\(typeName)' is not a BinaryMessagable type."
    )
    #expect(
      error.failureReason
        == "The type cannot decode binary data because"
        + " it does not conform to BinaryMessagable."
    )
    #expect(
      error.recoverySuggestion
        == "Ensure the message type conforms to BinaryMessagable protocol,"
        + " or use dictionary transport instead of binary."
    )
  }

  @Test("All ErrorKind cases have complete localization")
  func allErrorKindsHaveLocalization() {
    for error in Self.errors {
      #expect(error.errorDescription != nil, "Missing errorDescription for \(error.kind)")
      #expect(error.failureReason != nil, "Missing failureReason for \(error.kind)")
      #expect(
        error.recoverySuggestion != nil,
        "Missing recoverySuggestion for \(error.kind)"
      )

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
