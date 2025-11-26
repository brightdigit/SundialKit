//
// ConnectivityErrorWCErrorMappingTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

@Suite(
  "ConnectivityError WCError Mapping Tests",
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
struct ConnectivityErrorWCErrorMappingTests {
  // MARK: - WCError Mapping Tests

  @Test("WCError.sessionNotSupported maps correctly")
  func wcErrorSessionNotSupported() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.sessionNotSupported)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .sessionNotSupported)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.sessionNotActivated maps correctly")
  func wcErrorSessionNotActivated() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.sessionNotActivated)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .sessionNotActivated)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.sessionInactive maps correctly")
  func wcErrorSessionInactive() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.sessionInactive)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .sessionInactive)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.deviceNotPaired maps correctly")
  func wcErrorDeviceNotPaired() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.deviceNotPaired)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .deviceNotPaired)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.watchAppNotInstalled maps correctly")
  func wcErrorWatchAppNotInstalled() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.watchAppNotInstalled)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .companionAppNotInstalled)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.notReachable maps correctly")
  func wcErrorNotReachable() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.notReachable)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .notReachable)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("WCError.invalidParameter maps correctly")
  func wcErrorInvalidParameter() {
    #if canImport(WatchConnectivity)
      let wcError = WCError(.invalidParameter)
      let error = ConnectivityError(wcError: wcError)
      #expect(error == .invalidParameter)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
