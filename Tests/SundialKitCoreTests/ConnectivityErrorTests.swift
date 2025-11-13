//
//  ConnectivityErrorTests.swift
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

  // MARK: - Hashable Tests

  @Test("ConnectivityError is hashable")
  func errorHashable() {
    #if canImport(WatchConnectivity)
      let error1 = ConnectivityError.sessionNotSupported
      let error2 = ConnectivityError.sessionNotSupported
      let error3 = ConnectivityError.deviceNotPaired

      #expect(error1.hashValue == error2.hashValue)
      #expect(error1.hashValue != error3.hashValue)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Generic error codes with same value are equal")
  func genericErrorCodeEquality() {
    #if canImport(WatchConnectivity)
      let error1 = ConnectivityError.genericErrorCode(100)
      let error2 = ConnectivityError.genericErrorCode(100)
      let error3 = ConnectivityError.genericErrorCode(200)

      #expect(error1 == error2)
      #expect(error1 != error3)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Errors can be stored in a set")
  func errorInSet() {
    #if canImport(WatchConnectivity)
      var errors: Set<ConnectivityError> = []
      errors.insert(.sessionNotSupported)
      errors.insert(.deviceNotPaired)
      errors.insert(.sessionNotSupported)  // Duplicate

      #expect(errors.count == 2)
      #expect(errors.contains(.sessionNotSupported))
      #expect(errors.contains(.deviceNotPaired))
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Errors can be used as dictionary keys")
  func errorAsDictionaryKey() {
    #if canImport(WatchConnectivity)
      var errorCounts: [ConnectivityError: Int] = [:]
      errorCounts[.sessionNotSupported] = 1
      errorCounts[.deviceNotPaired] = 2

      #expect(errorCounts[.sessionNotSupported] == 1)
      #expect(errorCounts[.deviceNotPaired] == 2)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
