//
//  SundialKitNetworkTests.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

import Testing
@testable import SundialKitNetwork

@Suite("SundialKitNetwork Tests")
struct SundialKitNetworkTests {
  @Test("Version is correct")
  func versionIsCorrect() {
    #expect(SundialKitNetwork.version == "2.0.0")
  }
}
