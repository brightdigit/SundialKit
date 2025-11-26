//
// ConnectivityErrorTransferTests.swift
// Copyright (c) 2025 BrightDigit.
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
      let transferTimedOutReason =
        "The transfer did not complete within the expected time."
      #expect(error.failureReason == transferTimedOutReason)
      let transferTimedOutSuggestion =
        "Check network connectivity and try the transfer again."
      #expect(error.recoverySuggestion == transferTimedOutSuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Insufficient space error has proper localization")
  func insufficientSpaceLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.insufficientSpace

      #expect(error.errorDescription == "Insufficient storage space for the transfer.")
      let insufficientSpaceReason =
        "The receiving device does not have enough available storage."
      #expect(error.failureReason == insufficientSpaceReason)
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
      let fileNotAccessibleSuggestion =
        "Verify the file path is correct and the file exists."
      #expect(error.recoverySuggestion == fileNotAccessibleSuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
