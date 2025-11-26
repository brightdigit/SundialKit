//
// SerializationErrorContextTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

@Suite("SerializationError ErrorContext Tests")
struct SerializationErrorContextTests {
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
}
