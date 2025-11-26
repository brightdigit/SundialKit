//
// SerializationErrorThrowingTests.swift
// Copyright (c) 2025 BrightDigit.
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
