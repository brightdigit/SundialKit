//
//  ConnectivitySendContextTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Testing

@testable import SundialKitConnectivity
@testable import SundialKitCore

@Suite("Connectivity Send Context Tests")
struct ConnectivitySendContextTests {
  @Test("Context created from result matches expected pattern")
  func resultPatterns() {
    guard case .reply = ConnectivitySendContext(.success(.init())) else {
      Issue.record("Should be a reply")
      return
    }

    guard
      case .failure = ConnectivitySendContext(
        .failure(SundialError.sessionNotSupported)
      )
    else {
      Issue.record("Should be a failure")
      return
    }
  }
}
