//
//  SerializationErrorContextTests.swift
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
