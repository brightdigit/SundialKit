//
//  ConnectivityErrorConfigurationTests.swift
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
  "ConnectivityError Configuration Error Tests",
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
struct ConnectivityErrorConfigurationTests {
  @Test("Session missing delegate error has proper localization")
  func sessionMissingDelegateLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionMissingDelegate

      #expect(
        error.errorDescription == "The connectivity session is missing a required delegate."
      )
      #expect(
        error.failureReason
          == "A delegate must be set on the WatchConnectivity session before it can be activated."
      )
      #expect(
        error.recoverySuggestion
          == "Set a delegate on the WatchConnectivity session before calling activate()."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("File access denied error has proper localization")
  func fileAccessDeniedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.fileAccessDenied

      #expect(error.errorDescription == "Access to the file was denied by the system.")
      #expect(
        error.failureReason
          == "The app does not have the necessary permissions to access this file."
      )
      #expect(
        error.recoverySuggestion
          == "Check the app's file access permissions and request access if needed."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Delivery failed error has proper localization")
  func deliveryFailedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.deliveryFailed

      #expect(error.errorDescription == "Message delivery failed.")
      #expect(
        error.failureReason == "The message could not be delivered to the counterpart device."
      )
      #expect(
        error.recoverySuggestion
          == "Ensure the counterpart device is reachable and try sending the message again."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Watch only app error has proper localization")
  func watchOnlyAppLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.watchOnlyApp

      #expect(
        error.errorDescription
          == "The app is watch-only and cannot use certain connectivity features."
      )
      #expect(
        error.failureReason
          == "This is a watch-only app that requires a companion iOS app for full connectivity features."
      )
      #expect(
        error.recoverySuggestion
          == "Install the companion iOS app to enable full connectivity features."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
