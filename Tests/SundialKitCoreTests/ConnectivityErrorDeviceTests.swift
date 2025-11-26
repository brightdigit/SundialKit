//
// ConnectivityErrorDeviceTests.swift
// Copyright (c) 2025 BrightDigit.
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
