//
//  SundialKitConnectivityTests.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

import Testing

@testable import SundialKitConnectivity

@Suite("SundialKitConnectivity Tests")
internal struct SundialKitConnectivityTests {
  @Test("Version is correct")
  internal func versionIsCorrect() {
    #expect(SundialKitConnectivity.version == "2.0.0")
  }
}
