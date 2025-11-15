//
//  SerializationErrorThrowingTests.swift
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

@Suite("SerializationError Throwing Tests")
struct SerializationErrorThrowingTests {
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
