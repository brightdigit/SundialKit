//
// ConnectivityErrorMessagingTests.swift
// Copyright (c) 2025 BrightDigit.
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
      let replyFailedReason =
        "The counterpart encountered an error while processing the message."
      #expect(error.failureReason == replyFailedReason)
      let replyFailedSuggestion =
        "Check the message format and try again."
        + " The counterpart may need to handle the message differently."
      #expect(error.recoverySuggestion == replyFailedSuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Message reply timed out error has proper localization")
  func messageReplyTimedOutLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.messageReplyTimedOut

      #expect(error.errorDescription == "The message reply timed out.")
      let replyTimedOutReason =
        "The counterpart did not respond within the timeout period."
      #expect(error.failureReason == replyTimedOutReason)
      #expect(
        error.recoverySuggestion
          == "Try sending the message again."
          + " Consider checking if the counterpart is responsive."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Invalid parameter error has proper localization")
  func invalidParameterLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.invalidParameter

      let invalidParamDescription =
        "Invalid parameter provided to connectivity operation."
      #expect(error.errorDescription == invalidParamDescription)
      #expect(
        error.failureReason
          == "One or more parameters do not meet the required format or constraints."
      )
      let invalidParameterSuggestion =
        "Ensure all message data uses property list types"
        + " (String, Number, Date, Data, Array, Dictionary)."
      #expect(error.recoverySuggestion == invalidParameterSuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Payload too large error has proper localization")
  func payloadTooLargeLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.payloadTooLarge

      let payloadTooLargeDescription =
        "The message payload exceeds the maximum size limit."
      #expect(error.errorDescription == payloadTooLargeDescription)
      let payloadTooLargeReason =
        "The data exceeds WatchConnectivity's transfer size limits."
      #expect(error.failureReason == payloadTooLargeReason)
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
          == "The message contains types that cannot be"
          + " transmitted via WatchConnectivity."
      )
      let payloadUnsupportedSuggestion =
        "Use only property list types in message dictionaries."
      #expect(error.recoverySuggestion == payloadUnsupportedSuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
