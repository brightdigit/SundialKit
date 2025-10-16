//
//  ConnectivityReceiveContextTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import SundialKit
import Testing

@testable import SundialKitCore

@Suite("Connectivity Receive Context Tests")
struct ConnectivityReceiveContextTests {
  @Test("Reply handler is nil for application context")
  func replyHandler() {
    #expect(ConnectivityReceiveContext.applicationContext.replyHandler == nil)
    #expect(
      ConnectivityReceiveContext.replyWith { _ in
      }
      .replyHandler != nil
    )
  }

  @Test("Is application context flag works correctly")
  func isApplicationContext() {
    #expect(ConnectivityReceiveContext.applicationContext.isApplicationContext)
    #expect(
      !ConnectivityReceiveContext.replyWith { _ in
      }
      .isApplicationContext
    )
  }
}
