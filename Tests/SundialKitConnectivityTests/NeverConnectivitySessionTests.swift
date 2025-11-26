//
// NeverConnectivitySessionTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Testing

@testable import SundialKitConnectivity
@testable import SundialKitCore

@Suite("Never Connectivity Session Tests")
internal struct NeverConnectivitySessionTests {
  internal let session = NeverConnectivitySession()

  @Test("Delegate is nil")
  internal func delegateGet() {
    #expect(session.delegate == nil)
  }

  @Test("Is not reachable")
  internal func isNotReachable() {
    #expect(!session.isReachable)
  }

  @Test("Is not paired")
  internal func isNotPaired() {
    #expect(!session.isPaired)
  }

  @Test("Paired app is not installed")
  internal func isPairedAppNotInstalled() {
    #expect(!session.isPairedAppInstalled)
  }

  @Test("Activation state is not activated")
  internal func activationStateNotActivated() {
    #expect(session.activationState == .notActivated)
  }

  @Test("Activate throws session not supported error")
  internal func activateThrows() {
    #expect(throws: SundialError.self) {
      try session.activate()
    }
  }

  @Test("Update application context throws session not supported error")
  internal func updateApplicationContextThrows() {
    #expect(throws: SundialError.self) {
      try session.updateApplicationContext(.init())
    }
  }

  @Test("Send message returns session not supported error")
  internal func sendMessageReturnsError() async {
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
