//
//  SerializationErrorStaticPropertiesTests.swift
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
