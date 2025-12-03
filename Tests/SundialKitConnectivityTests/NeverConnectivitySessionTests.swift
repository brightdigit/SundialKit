//
//  NeverConnectivitySessionTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
