//
//  BinaryMessagableTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import SundialKitCore
import Testing

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
    value = data.withUnsafeBytes { $0.load(as: UInt32.self) }
  }

  // Binary encoding (no type info)
  internal func encode() throws -> Data {
    withUnsafeBytes(of: value) { Data($0) }
  }
}

@Suite("BinaryMessagable Tests")
internal struct BinaryMessagableTests {
  @Test("Binary message automatically implements Messagable")
  internal func binaryAutomaticallyImplementsMessagable() throws {
    let original = TestBinaryMessage(value: 42)

    // Should have parameters() auto-implemented
    let params = original.parameters()
    #expect(params[MessagableKeys.dataKey] != nil)

    // Should be able to decode from parameters
    let decoded = try TestBinaryMessage(from: params)
    #expect(decoded.value == original.value)
  }

  @Test("Binary message has default key from type name")
  internal func binaryMessageDefaultKey() {
    #expect(TestBinaryMessage.key == "TestBinaryMessage")
  }

  @Test("Binary message encoding and decoding roundtrip")
  internal func binaryEncodingDecoding() throws {
    let original = TestBinaryMessage(value: 12_345)

    // Encode to binary
    let data = try original.encode()
    #expect(data.count == 4)

    // Decode from binary
    let decoded = try TestBinaryMessage(from: data)
    #expect(decoded.value == original.value)
  }

  @Test("Binary message works with MessageDecoder")
  internal func binaryMessageDecoder() throws {
    let decoder = MessageDecoder(messagableTypes: [TestBinaryMessage.self])
    let original = TestBinaryMessage(value: 999)

    // Create message dictionary
    let message = original.message()
    #expect(message[MessagableKeys.typeKey] as? String == "TestBinaryMessage")
    #expect(message[MessagableKeys.parametersKey] != nil)

    // Decode through MessageDecoder
    let decoded = try decoder.decode(message) as? TestBinaryMessage
    #expect(decoded?.value == original.value)
  }

  @Test("Binary message throws on invalid data size")
  internal func binaryMessageInvalidSize() {
    let invalidData = Data([1, 2])  // Too small

    #expect(throws: SerializationError.self) {
      _ = try TestBinaryMessage(from: invalidData)
    }
  }

  @Test("Binary message throws on missing binary data in parameters")
  internal func binaryMessageMissingData() {
    let emptyParams: [String: any Sendable] = [:]

    #expect(throws: SerializationError.self) {
      _ = try TestBinaryMessage(from: emptyParams)
    }
  }
}
