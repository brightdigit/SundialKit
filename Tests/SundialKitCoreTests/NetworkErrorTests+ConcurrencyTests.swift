//
//  NetworkErrorTests+ConcurrencyTests.swift
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

extension NetworkErrorTests {
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

      #expect(
        error.errorDescription?.isEmpty == false,
        "Empty errorDescription for \(error)")
      #expect(
        error.failureReason?.isEmpty == false,
        "Empty failureReason for \(error)")
      #expect(
        error.recoverySuggestion?.isEmpty == false,
        "Empty recoverySuggestion for \(error)")
    }
  }
}
