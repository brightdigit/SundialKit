//
//  ConnectivityError+MessagingTests.swift
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
  "ConnectivityError Messaging Error Tests",
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
struct ConnectivityErrorMessagingTests {
  @Test("Message reply failed error has proper localization")
  func messageReplyFailedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.messageReplyFailed

      #expect(error.errorDescription == "The message reply operation failed.")
      #expect(
        error.failureReason == "The counterpart encountered an error while processing the message."
      )
      #expect(
        error.recoverySuggestion
          // swiftlint:disable:next line_length
          == "Check the message format and try again. The counterpart may need to handle the message differently."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Message reply timed out error has proper localization")
  func messageReplyTimedOutLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.messageReplyTimedOut

      #expect(error.errorDescription == "The message reply timed out.")
      #expect(
        error.failureReason == "The counterpart did not respond within the timeout period."
      )
      #expect(
        error.recoverySuggestion
          == "Try sending the message again. Consider checking if the counterpart is responsive."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Invalid parameter error has proper localization")
  func invalidParameterLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.invalidParameter

      #expect(error.errorDescription == "Invalid parameter provided to connectivity operation.")
      #expect(
        error.failureReason
          == "One or more parameters do not meet the required format or constraints."
      )
      #expect(
        error.recoverySuggestion
          // swiftlint:disable:next line_length
          == "Ensure all message data uses property list types (String, Number, Date, Data, Array, Dictionary)."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Payload too large error has proper localization")
  func payloadTooLargeLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.payloadTooLarge

      #expect(error.errorDescription == "The message payload exceeds the maximum size limit.")
      #expect(error.failureReason == "The data exceeds WatchConnectivity's transfer size limits.")
      #expect(
        error.recoverySuggestion
          == "Reduce the message size or split the data into multiple smaller messages."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Payload unsupported types error has proper localization")
  func payloadUnsupportedTypesLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.payloadUnsupportedTypes

      #expect(error.errorDescription == "The message payload contains unsupported types.")
      #expect(
        error.failureReason
          == "The message contains types that cannot be transmitted via WatchConnectivity."
      )
      #expect(
        error.recoverySuggestion == "Use only property list types in message dictionaries."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
