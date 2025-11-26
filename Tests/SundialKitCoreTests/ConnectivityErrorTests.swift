//
// ConnectivityErrorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

@Suite(
  "ConnectivityError Tests",
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
struct ConnectivityErrorTests {
  // MARK: - Error Case Construction Tests

  @Test("Session error cases can be constructed")
  func sessionErrorCases() {
    #if canImport(WatchConnectivity)
      let notSupported = ConnectivityError.sessionNotSupported
      let notActivated = ConnectivityError.sessionNotActivated
      let inactive = ConnectivityError.sessionInactive

      #expect(notSupported == .sessionNotSupported)
      #expect(notActivated == .sessionNotActivated)
      #expect(inactive == .sessionInactive)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Device error cases can be constructed")
  func deviceErrorCases() {
    #if canImport(WatchConnectivity)
      let notPaired = ConnectivityError.deviceNotPaired
      let appNotInstalled = ConnectivityError.companionAppNotInstalled
      let notReachable = ConnectivityError.notReachable

      #expect(notPaired == .deviceNotPaired)
      #expect(appNotInstalled == .companionAppNotInstalled)
      #expect(notReachable == .notReachable)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Messaging error cases can be constructed")
  func messagingErrorCases() {
    #if canImport(WatchConnectivity)
      let replyFailed = ConnectivityError.messageReplyFailed
      let replyTimedOut = ConnectivityError.messageReplyTimedOut
      let invalidParam = ConnectivityError.invalidParameter
      let payloadTooLarge = ConnectivityError.payloadTooLarge
      let payloadUnsupported = ConnectivityError.payloadUnsupportedTypes

      #expect(replyFailed == .messageReplyFailed)
      #expect(replyTimedOut == .messageReplyTimedOut)
      #expect(invalidParam == .invalidParameter)
      #expect(payloadTooLarge == .payloadTooLarge)
      #expect(payloadUnsupported == .payloadUnsupportedTypes)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Transfer error cases can be constructed")
  func transferErrorCases() {
    #if canImport(WatchConnectivity)
      let timedOut = ConnectivityError.transferTimedOut
      let insufficientSpace = ConnectivityError.insufficientSpace
      let fileNotAccessible = ConnectivityError.fileNotAccessible

      #expect(timedOut == .transferTimedOut)
      #expect(insufficientSpace == .insufficientSpace)
      #expect(fileNotAccessible == .fileNotAccessible)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Configuration error cases can be constructed")
  func configurationErrorCases() {
    #if canImport(WatchConnectivity)
      let missingDelegate = ConnectivityError.sessionMissingDelegate
      let accessDenied = ConnectivityError.fileAccessDenied
      let deliveryFailed = ConnectivityError.deliveryFailed
      let watchOnly = ConnectivityError.watchOnlyApp

      #expect(missingDelegate == .sessionMissingDelegate)
      #expect(accessDenied == .fileAccessDenied)
      #expect(deliveryFailed == .deliveryFailed)
      #expect(watchOnly == .watchOnlyApp)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Generic error code case can be constructed")
  func genericErrorCodeCase() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.genericErrorCode(999)

      if case .genericErrorCode(let code) = error {
        #expect(code == 999)
      } else {
        Issue.record("Expected genericErrorCode case")
      }
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
