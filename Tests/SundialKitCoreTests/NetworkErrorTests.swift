//
// NetworkErrorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

@Suite("NetworkError Tests")
struct NetworkErrorTests {
  // MARK: - Error Case Construction Tests

  @Test("Monitoring unavailable error can be constructed")
  func monitoringUnavailableConstruction() {
    let error = NetworkError.monitoringUnavailable
    if case .monitoringUnavailable = error {
      #expect(Bool(true))
    } else {
      Issue.record("Expected monitoringUnavailable case")
    }
  }

  @Test("Path update failed error can be constructed")
  func pathUpdateFailedConstruction() {
    let error = NetworkError.pathUpdateFailed
    if case .pathUpdateFailed = error {
      #expect(Bool(true))
    } else {
      Issue.record("Expected pathUpdateFailed case")
    }
  }

  @Test("Ping timeout error can be constructed")
  func pingTimeoutConstruction() {
    let error = NetworkError.pingTimeout
    if case .pingTimeout = error {
      #expect(Bool(true))
    } else {
      Issue.record("Expected pingTimeout case")
    }
  }

  @Test("Ping failed error can be constructed with reason")
  func pingFailedConstruction() {
    let reason = "Connection refused"
    let error = NetworkError.pingFailed(reason)

    if case .pingFailed(let errorReason) = error {
      #expect(errorReason == reason)
    } else {
      Issue.record("Expected pingFailed case")
    }
  }

  @Test("Invalid configuration error can be constructed")
  func invalidConfigurationConstruction() {
    let error = NetworkError.invalidConfiguration
    if case .invalidConfiguration = error {
      #expect(Bool(true))
    } else {
      Issue.record("Expected invalidConfiguration case")
    }
  }

  // MARK: - LocalizedError Conformance Tests

  @Test("Monitoring unavailable has proper localization")
  func monitoringUnavailableLocalization() {
    let error = NetworkError.monitoringUnavailable

    #expect(
      error.errorDescription
        == "Network monitoring is not available on this platform or configuration."
    )
    let monitoringUnavailableReason =
      "The current platform or system configuration"
      + " does not support network monitoring."
    #expect(error.failureReason == monitoringUnavailableReason)
    let monitoringUnavailableSuggestion =
      "Check platform requirements and ensure"
      + " network monitoring is supported on this device."
    #expect(error.recoverySuggestion == monitoringUnavailableSuggestion)
  }

  @Test("Path update failed has proper localization")
  func pathUpdateFailedLocalization() {
    let error = NetworkError.pathUpdateFailed

    #expect(error.errorDescription == "Failed to update network path status.")
    let pathUpdateFailedReason =
      "The system was unable to provide network path information."
    #expect(error.failureReason == pathUpdateFailedReason)
    #expect(
      error.recoverySuggestion
        == "Try restarting network monitoring or check system network settings."
    )
  }

  @Test("Ping timeout has proper localization")
  func pingTimeoutLocalization() {
    let error = NetworkError.pingTimeout

    #expect(error.errorDescription == "Network connectivity verification timed out.")
    let pingTimeoutReason =
      "The network did not respond within the expected time limit."
    #expect(error.failureReason == pingTimeoutReason)
    let pingTimeoutSuggestion =
      "Check network connectivity and try again."
      + " Consider increasing the timeout interval."
    #expect(error.recoverySuggestion == pingTimeoutSuggestion)
  }

  @Test("Ping failed has proper localization with reason")
  func pingFailedLocalization() {
    let reason = "DNS resolution failed"
    let error = NetworkError.pingFailed(reason)

    #expect(error.errorDescription == "Network ping failed: \(reason)")
    #expect(
      error.failureReason == "The network connectivity verification encountered an error."
    )
    #expect(
      error.recoverySuggestion
        == "Verify network configuration and ensure the target is reachable."
    )
  }

  @Test("Invalid configuration has proper localization")
  func invalidConfigurationLocalization() {
    let error = NetworkError.invalidConfiguration

    #expect(error.errorDescription == "Invalid network monitoring configuration.")
    #expect(
      error.failureReason
        == "The provided monitoring configuration contains invalid parameters."
    )
    let invalidConfigSuggestion =
      "Review monitoring configuration parameters"
      + " and ensure all required values are provided."
    #expect(error.recoverySuggestion == invalidConfigSuggestion)
  }
}
