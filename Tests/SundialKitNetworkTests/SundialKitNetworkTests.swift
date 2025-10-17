//
//  SundialKitNetworkTests.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

import Testing

@testable import SundialKitNetwork

@Suite("SundialKitNetwork Tests")
internal struct SundialKitNetworkTests {
  @Test("Version is correct")
  internal func versionIsCorrect() {
    #expect(SundialKitNetwork.version == "2.0.0")
  }
}
