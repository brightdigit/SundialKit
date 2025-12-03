//
//  ConnectivityError+TransferTests.swift
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
  "ConnectivityError Transfer Error Tests",
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
struct ConnectivityErrorTransferTests {
  @Test("Transfer timed out error has proper localization")
  func transferTimedOutLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.transferTimedOut

      #expect(error.errorDescription == "The data transfer operation timed out.")
      #expect(error.failureReason == "The transfer did not complete within the expected time.")
      #expect(
        error.recoverySuggestion == "Check network connectivity and try the transfer again."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Insufficient space error has proper localization")
  func insufficientSpaceLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.insufficientSpace

      #expect(error.errorDescription == "Insufficient storage space for the transfer.")
      #expect(
        error.failureReason == "The receiving device does not have enough available storage."
      )
      #expect(
        error.recoverySuggestion
          == "Free up storage space on the receiving device and retry the transfer."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("File not accessible error has proper localization")
  func fileNotAccessibleLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.fileNotAccessible

      #expect(error.errorDescription == "The file is not accessible for transfer.")
      #expect(
        error.failureReason == "The specified file cannot be accessed or does not exist."
      )
      #expect(error.recoverySuggestion == "Verify the file path is correct and the file exists.")
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
