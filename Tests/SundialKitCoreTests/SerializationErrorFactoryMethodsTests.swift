//
// SerializationErrorFactoryMethodsTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

@Suite("SerializationError Factory Methods Tests")
struct SerializationErrorFactoryMethodsTests {
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
}
