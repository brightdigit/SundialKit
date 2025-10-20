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
struct TestBinaryMessage: BinaryMessagable {
  let value: UInt32

  // Regular initializer for creating messages
  init(value: UInt32) {
    self.value = value
  }

  // Binary encoding (no type info)
  func encode() throws -> Data {
    withUnsafeBytes(of: value) { Data($0) }
  }

  // Binary decoding (no type info)
  init(from data: Data) throws {
    guard data.count == MemoryLayout<UInt32>.size else {
      throw SerializationError.invalidDataSize
    }
    value = data.withUnsafeBytes { $0.load(as: UInt32.self) }
  }
}

@Suite("BinaryMessagable Tests")
struct BinaryMessagableTests {
  @Test("Binary message automatically implements Messagable")
  func binaryAutomaticallyImplementsMessagable() throws {
    let original = TestBinaryMessage(value: 42)

    // Should have parameters() auto-implemented
    let params = original.parameters()
    #expect(params[MessagableKeys.dataKey] != nil)

    // Should be able to decode from parameters
    let decoded = try TestBinaryMessage(from: params)
    #expect(decoded.value == original.value)
  }

  @Test("Binary message has default key from type name")
  func binaryMessageDefaultKey() {
    #expect(TestBinaryMessage.key == "TestBinaryMessage")
  }

  @Test("Binary message encoding and decoding roundtrip")
  func binaryEncodingDecoding() throws {
    let original = TestBinaryMessage(value: 12345)

    // Encode to binary
    let data = try original.encode()
    #expect(data.count == 4)

    // Decode from binary
    let decoded = try TestBinaryMessage(from: data)
    #expect(decoded.value == original.value)
  }

  @Test("Binary message works with MessageDecoder")
  func binaryMessageDecoder() throws {
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
  func binaryMessageInvalidSize() {
    let invalidData = Data([1, 2])  // Too small

    #expect(throws: SerializationError.self) {
      _ = try TestBinaryMessage(from: invalidData)
    }
  }

  @Test("Binary message throws on missing binary data in parameters")
  func binaryMessageMissingData() {
    let emptyParams: [String: any Sendable] = [:]

    #expect(throws: SerializationError.self) {
      _ = try TestBinaryMessage(from: emptyParams)
    }
  }
}
