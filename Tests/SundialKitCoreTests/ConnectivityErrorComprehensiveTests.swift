//
//  ConnectivityErrorComprehensiveTests.swift
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
