//
//  MessagableTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitConnectivity

@Suite("Messagable Tests")
struct MessagableTests {
  @Test("Message encoding includes type key and parameters")
  func messageEncoding() {
    let mockMessage = MockMessage()
    let dict = mockMessage.message()

    #expect(dict[MessagableKeys.typeKey] as? String == MockMessage.key)

    let actualParams = dict[MessagableKeys.parametersKey]
    guard let params = actualParams as? [String: any Sendable] else {
      Issue.record("Parameters should not be nil")
      return
    }

    #expect(params[mockMessage.key] as? UUID == mockMessage.value)
  }
}
