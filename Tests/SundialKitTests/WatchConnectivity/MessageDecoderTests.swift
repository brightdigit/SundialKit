//
//  MessageDecoderTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Testing

@testable import SundialKit

@Suite("Message Decoder Tests")
struct MessageDecoderTests {
  @Test("Decoder can decode messages")
  func decodeMessage() throws {
    let decoder = MessageDecoder(messagableTypes: [MockMessage.self])
    let expMessage = MockMessage()
    let dict = expMessage.message()
    let actualMessage = decoder.decode(dict) as? MockMessage
    #expect(expMessage == actualMessage)
  }
}
