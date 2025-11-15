//
//  ConnectivityError+SessionTests.swift
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

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

@Suite(
  "ConnectivityError Session Error Tests",
  .enabled(
    if: {
      #if canImport(WatchConnectivity)
        return WCSession.isSupported()
      #else
        return false
      #endif
    }()
  )
)
struct ConnectivityErrorSessionTests {
  @Test("Session not supported error has proper localization")
  func sessionNotSupportedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionNotSupported

      #expect(error.errorDescription == "WatchConnectivity is not supported on this device.")
      #expect(
        error.failureReason
          == "WatchConnectivity is only available on iPhone and Apple Watch devices."
      )
      #expect(
        error.recoverySuggestion
          == "WatchConnectivity features are only available on compatible devices."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Session not activated error has proper localization")
  func sessionNotActivatedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionNotActivated

      #expect(error.errorDescription == "The connectivity session has not been activated.")
      #expect(
        error.failureReason
          == "The session must be activated before sending or receiving messages."
      )
      #expect(
        error.recoverySuggestion
          == "Call activate() on the connectivity manager before using messaging features."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Session inactive error has proper localization")
  func sessionInactiveLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionInactive

      #expect(error.errorDescription == "The connectivity session is inactive.")
      #expect(error.failureReason == "The session is transitioning to a deactivated state.")
      #expect(
        error.recoverySuggestion
          == "Wait for the session to become active again or reactivate it."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
