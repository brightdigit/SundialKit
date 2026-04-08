//
//  TestBinaryMessage.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import SundialKitCore

@testable import SundialKitConnectivity

// Test message using simple binary encoding
internal struct TestBinaryMessage: BinaryMessagable {
  internal let value: UInt32

  // Regular initializer for creating messages
  internal init(value: UInt32) {
    self.value = value
  }

  // Binary decoding (no type info)
  internal init(from data: Data) throws {
    guard data.count == MemoryLayout<UInt32>.size else {
      throw SerializationError.invalidDataSize
    }
    value = data.withUnsafeBytes { $0.loadUnaligned(as: UInt32.self) }
  }

  // Binary encoding (no type info)
  internal func encode() throws -> Data {
    withUnsafeBytes(of: value) { Data($0) }
  }
}
