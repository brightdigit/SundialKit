//
// ConnectivityErrorSessionTests.swift
// Copyright (c) 2025 BrightDigit.
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
