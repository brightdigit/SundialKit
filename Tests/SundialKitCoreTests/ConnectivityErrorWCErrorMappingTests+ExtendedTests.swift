//
//  ConnectivityErrorWCErrorMappingTests+ExtendedTests.swift
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

extension ConnectivityErrorWCErrorMappingTests {
  @Test("WCError.payloadTooLarge maps correctly")
  func wcErrorPayloadTooLarge() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.payloadTooLarge)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .payloadTooLarge)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.payloadUnsupportedTypes maps correctly")
  func wcErrorPayloadUnsupportedTypes() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.payloadUnsupportedTypes)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .payloadUnsupportedTypes)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.messageReplyFailed maps correctly")
  func wcErrorMessageReplyFailed() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.messageReplyFailed)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .messageReplyFailed)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.messageReplyTimedOut maps correctly")
  func wcErrorMessageReplyTimedOut() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.messageReplyTimedOut)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .messageReplyTimedOut)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.transferTimedOut maps correctly")
  func wcErrorTransferTimedOut() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.transferTimedOut)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .transferTimedOut)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.insufficientSpace maps correctly")
  func wcErrorInsufficientSpace() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.insufficientSpace)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .insufficientSpace)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.sessionMissingDelegate maps correctly")
  func wcErrorSessionMissingDelegate() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.sessionMissingDelegate)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .sessionMissingDelegate)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.fileAccessDenied maps correctly")
  func wcErrorFileAccessDenied() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.fileAccessDenied)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .fileAccessDenied)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.deliveryFailed maps correctly")
  func wcErrorDeliveryFailed() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.deliveryFailed)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .deliveryFailed)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.companionAppNotInstalled maps correctly")
  func wcErrorCompanionAppNotInstalled() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.companionAppNotInstalled)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .companionAppNotInstalled)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.watchOnlyApp maps correctly")
  func wcErrorWatchOnlyApp() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.watchOnlyApp)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .watchOnlyApp)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
