//
// MockMessage.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import SundialKitCore

@testable import SundialKitConnectivity

internal struct MockMessage: Messagable, Equatable {
  internal static let key: String = UUID().uuidString
  internal let key: String
  internal let value: UUID
  internal init() {
    key = UUID().uuidString
    value = UUID()
  }

  internal init(from parameters: [String: any Sendable]) throws {
    guard let pair = parameters.first else {
      throw SerializationError.missingField("parameters")
    }

    guard let value = pair.value as? UUID else {
      throw SerializationError.typeMismatch(
        key: pair.key,
        expected: "UUID",
        actual: String(describing: type(of: pair.value))
      )
    }

    key = pair.key
    self.value = value
  }

  internal func parameters() -> [String: any Sendable] {
    [key: value]
  }
}
