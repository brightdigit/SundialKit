//
//  ConnectivityErrorGenericTests.swift
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
