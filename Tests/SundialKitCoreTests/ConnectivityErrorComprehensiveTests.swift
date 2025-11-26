//
// ConnectivityErrorComprehensiveTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

@Suite(
  "ConnectivityError Comprehensive Tests",
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
struct ConnectivityErrorComprehensiveTests {
  // MARK: - All Errors Have Complete Localization

  static let allErrors: [ConnectivityError] = [
    .sessionNotSupported,
    .sessionNotActivated,
    .sessionInactive,
    .deviceNotPaired,
    .companionAppNotInstalled,
    .notReachable,
    .messageReplyFailed,
    .messageReplyTimedOut,
    .invalidParameter,
    .payloadTooLarge,
    .payloadUnsupportedTypes,
    .transferTimedOut,
    .insufficientSpace,
    .fileNotAccessible,
    .sessionMissingDelegate,
    .fileAccessDenied,
    .deliveryFailed,
    .watchOnlyApp,
  ]
  @Test("All non-generic errors have non-nil localization")
  func allErrorsHaveLocalization() {
    #if canImport(WatchConnectivity)

      for error in Self.allErrors {
        #expect(error.errorDescription != nil, "Missing errorDescription for \(error)")
        #expect(error.failureReason != nil, "Missing failureReason for \(error)")
        #expect(error.recoverySuggestion != nil, "Missing recoverySuggestion for \(error)")

        // Ensure strings are not empty
        let descriptionExists = error.errorDescription != nil
        let failureExists = error.failureReason != nil
        let suggestionExists = error.recoverySuggestion != nil

        #expect(
          error.errorDescription?.isEmpty == false,
          "Empty errorDescription for \(error)"
        )

        #expect(
          error.failureReason?.isEmpty == false,
          "Empty failureReason for \(error)"
        )

        #expect(
          error.recoverySuggestion?.isEmpty == false,
          "Empty recoverySuggestion for \(error)"
        )
      }
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
