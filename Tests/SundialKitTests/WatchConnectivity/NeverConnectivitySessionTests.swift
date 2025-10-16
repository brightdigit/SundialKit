//
//  NeverConnectivitySessionTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Testing

@testable import SundialKit
@testable import SundialKitConnectivity

@Suite("Never Connectivity Session Tests")
struct NeverConnectivitySessionTests {
  let session = NeverConnectivitySession()

  @Test("Delegate is nil")
  func delegateGet() {
    #expect(session.delegate == nil)
  }

  @Test("Is not reachable")
  func isNotReachable() {
    #expect(!session.isReachable)
  }

  @Test("Is not paired")
  func isNotPaired() {
    #expect(!session.isPaired)
  }

  @Test("Paired app is not installed")
  func isPairedAppNotInstalled() {
    #expect(!session.isPairedAppInstalled)
  }

  @Test("Activation state is not activated")
  func activationStateNotActivated() {
    #expect(session.activationState == .notActivated)
  }

  @Test("Activate throws session not supported error")
  func activateThrows() {
    #expect(throws: SundialError.self) {
      try session.activate()
    }
  }

  @Test("Update application context throws session not supported error")
  func updateApplicationContextThrows() {
    #expect(throws: SundialError.self) {
      try session.updateApplicationContext(.init())
    }
  }

  @Test("Send message returns session not supported error")
  func sendMessageReturnsError() async {
    await confirmation("Message sent with error") { confirm in
      session.sendMessage(.init()) { result in
        guard case .failure(let error as SundialError) = result else {
          return
        }
        #expect(error == .sessionNotSupported)
        confirm()
      }
    }
  }
}
