//
// ConnectivityErrorGenericTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

@Suite(
  "ConnectivityError Generic Error Tests",
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
struct ConnectivityErrorGenericTests {
  @Test("Generic error code has default localization")
  func genericErrorCodeLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.genericErrorCode(999)

      #expect(error.errorDescription == "Connectivity error: 999")
      #expect(
        error.failureReason == "An unexpected error occurred during the connectivity operation."
      )
      #expect(
        error.recoverySuggestion
          == "Check the underlying error for more details and try the operation again."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Generic error code shows different codes in description")
  func genericErrorCodeVariations() {
    #if canImport(WatchConnectivity)
      let error1 = ConnectivityError.genericErrorCode(100)
      let error2 = ConnectivityError.genericErrorCode(200)

      #expect(error1.errorDescription == "Connectivity error: 100")
      #expect(error2.errorDescription == "Connectivity error: 200")

      // Failure reason and recovery suggestion should be the same
      #expect(error1.failureReason == error2.failureReason)
      #expect(error1.recoverySuggestion == error2.recoverySuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
