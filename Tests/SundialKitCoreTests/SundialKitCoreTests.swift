//
//  SundialKitCoreTests.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

import Testing
@testable import SundialKitCore

@Suite("SundialKitCore Tests")
struct SundialKitCoreTests {
  @Test("Version is correct")
  func versionIsCorrect() {
    #expect(SundialKitCore.version == "2.0.0")
  }
}
