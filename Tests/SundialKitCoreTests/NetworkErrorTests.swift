//
//  NetworkErrorTests.swift
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
    #expect(
      error.failureReason
        == "The current platform or system configuration does not support network monitoring."
    )
    #expect(
      error.recoverySuggestion
        == "Check platform requirements and ensure network monitoring is supported on this device."
    )
  }

  @Test("Path update failed has proper localization")
  func pathUpdateFailedLocalization() {
    let error = NetworkError.pathUpdateFailed

    #expect(error.errorDescription == "Failed to update network path status.")
    #expect(error.failureReason == "The system was unable to provide network path information.")
    #expect(
      error.recoverySuggestion
        == "Try restarting network monitoring or check system network settings."
    )
  }

  @Test("Ping timeout has proper localization")
  func pingTimeoutLocalization() {
    let error = NetworkError.pingTimeout

    #expect(error.errorDescription == "Network connectivity verification timed out.")
    #expect(error.failureReason == "The network did not respond within the expected time limit.")
    #expect(
      error.recoverySuggestion
        == "Check network connectivity and try again. Consider increasing the timeout interval."
    )
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
    #expect(
      error.recoverySuggestion
        == "Review monitoring configuration parameters and ensure all required values are provided."
    )
  }

  // MARK: - Error Throwing Tests

  @Test("NetworkError can be thrown and caught")
  func errorThrowing() throws {
    func throwError() throws {
      throw NetworkError.monitoringUnavailable
    }

    #expect(throws: NetworkError.self) {
      try throwError()
    }
  }

  @Test("Specific NetworkError case can be caught")
  func specificErrorCatching() {
    func throwPingTimeout() throws {
      throw NetworkError.pingTimeout
    }

    do {
      try throwPingTimeout()
      Issue.record("Expected error to be thrown")
    } catch NetworkError.pingTimeout {
      // Success - caught the expected error
      #expect(Bool(true))
    } catch {
      Issue.record("Caught unexpected error: \(error)")
    }
  }

  @Test("PingFailed reason can be extracted when caught")
  func pingFailedReasonExtraction() {
    let expectedReason = "Host unreachable"

    func throwPingFailed() throws {
      throw NetworkError.pingFailed(expectedReason)
    }

    do {
      try throwPingFailed()
      Issue.record("Expected error to be thrown")
    } catch NetworkError.pingFailed(let reason) {
      #expect(reason == expectedReason)
    } catch {
      Issue.record("Caught unexpected error: \(error)")
    }
  }

  // MARK: - Error as Any Tests

  @Test("NetworkError can be cast from Error protocol")
  func errorProtocolCasting() {
    let error: any Error = NetworkError.invalidConfiguration

    if let networkError = error as? NetworkError {
      if case .invalidConfiguration = networkError {
        #expect(Bool(true))
      } else {
        Issue.record("Expected invalidConfiguration case")
      }
    } else {
      Issue.record("Failed to cast Error to NetworkError")
    }
  }

  @Test("LocalizedError properties accessible through Error protocol")
  func localizedErrorThroughProtocol() {
    let error: any Error = NetworkError.pathUpdateFailed

    if let localizedError = error as? any LocalizedError {
      #expect(localizedError.errorDescription != nil)
      #expect(localizedError.failureReason != nil)
      #expect(localizedError.recoverySuggestion != nil)
    } else {
      Issue.record("Failed to cast Error to LocalizedError")
    }
  }

  // MARK: - All Errors Have Localization

  @Test("All error cases have complete localization")
  func allErrorsHaveLocalization() {
    let errors: [NetworkError] = [
      .monitoringUnavailable,
      .pathUpdateFailed,
      .pingTimeout,
      .pingFailed("test reason"),
      .invalidConfiguration,
    ]

    for error in errors {
      #expect(error.errorDescription != nil, "Missing errorDescription for \(error)")
      #expect(error.failureReason != nil, "Missing failureReason for \(error)")
      #expect(error.recoverySuggestion != nil, "Missing recoverySuggestion for \(error)")

      #expect(!error.errorDescription!.isEmpty, "Empty errorDescription for \(error)")
      #expect(!error.failureReason!.isEmpty, "Empty failureReason for \(error)")
      #expect(!error.recoverySuggestion!.isEmpty, "Empty recoverySuggestion for \(error)")
    }
  }
}
