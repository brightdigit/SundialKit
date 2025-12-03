//
//  ConnectivityError+DeviceTests.swift
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
  "ConnectivityError Device Error Tests",
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
struct ConnectivityErrorDeviceTests {
  @Test("Device not paired error has proper localization")
  func deviceNotPairedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.deviceNotPaired

      #expect(error.errorDescription == "No companion device is paired.")
      #expect(error.failureReason == "This device is not paired with a companion device.")
      #expect(
        error.recoverySuggestion
          == "Pair an Apple Watch with this iPhone or an iPhone with this Apple Watch."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Companion app not installed error has proper localization")
  func companionAppNotInstalledLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.companionAppNotInstalled

      #expect(
        error.errorDescription == "The companion app is not installed on the paired device."
      )
      #expect(
        error.failureReason == "The corresponding app is not installed on the paired device."
      )
      #expect(error.recoverySuggestion == "Install the companion app on the paired device.")
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Not reachable error has proper localization")
  func notReachableLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.notReachable

      #expect(error.errorDescription == "The counterpart device is not currently reachable.")
      #expect(
        error.failureReason
          == "The device may be out of range, powered off, or the app may not be running."
      )
      #expect(
        error.recoverySuggestion
          == "Ensure both devices are powered on, within range, and the app is running on the counterpart."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
