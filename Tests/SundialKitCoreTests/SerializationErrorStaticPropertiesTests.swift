//
// SerializationErrorStaticPropertiesTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

@Suite("SerializationError Static Properties Tests")
struct SerializationErrorStaticPropertiesTests {
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
}
