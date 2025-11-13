//
//  ConnectivityError+LocalizedErrorTests.swift
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
  "ConnectivityError LocalizedError Tests",
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
struct ConnectivityErrorLocalizedErrorTests {
  // MARK: - Session Error Localization Tests

  @Test("Session not supported error has proper localization")
  func sessionNotSupportedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionNotSupported

      #expect(error.errorDescription == "WatchConnectivity is not supported on this device.")
      #expect(
        error.failureReason
          == "WatchConnectivity is only available on iPhone and Apple Watch devices."
      )
      #expect(
        error.recoverySuggestion
          == "WatchConnectivity features are only available on compatible devices."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Session not activated error has proper localization")
  func sessionNotActivatedLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionNotActivated

      #expect(error.errorDescription == "The connectivity session has not been activated.")
      #expect(
        error.failureReason
          == "The session must be activated before sending or receiving messages."
      )
      #expect(
        error.recoverySuggestion
          == "Call activate() on the connectivity manager before using messaging features."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Session inactive error has proper localization")
  func sessionInactiveLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.sessionInactive

      #expect(error.errorDescription == "The connectivity session is inactive.")
      #expect(error.failureReason == "The session is transitioning to a deactivated state.")
      #expect(
        error.recoverySuggestion
          == "Wait for the session to become active again or reactivate it."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  // MARK: - Device Error Localization Tests

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

  // MARK: - Messaging Error Localization Tests

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

  // MARK: - Transfer Error Localization Tests

  @Test("Transfer timed out error has proper localization")
  func transferTimedOutLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.transferTimedOut

      #expect(error.errorDescription == "The data transfer operation timed out.")
      #expect(error.failureReason == "The transfer did not complete within the expected time.")
      #expect(
        error.recoverySuggestion == "Check network connectivity and try the transfer again."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Insufficient space error has proper localization")
  func insufficientSpaceLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.insufficientSpace

      #expect(error.errorDescription == "Insufficient storage space for the transfer.")
      #expect(
        error.failureReason == "The receiving device does not have enough available storage."
      )
      #expect(
        error.recoverySuggestion
          == "Free up storage space on the receiving device and retry the transfer."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("File not accessible error has proper localization")
  func fileNotAccessibleLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.fileNotAccessible

      #expect(error.errorDescription == "The file is not accessible for transfer.")
      #expect(
        error.failureReason == "The specified file cannot be accessed or does not exist."
      )
      #expect(error.recoverySuggestion == "Verify the file path is correct and the file exists.")
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  // MARK: - Configuration Error Localization Tests

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

  // MARK: - Generic Error Code Localization Tests

  @Test("Generic error code has default localization")
  func genericErrorCodeLocalization() {
    #if canImport(WatchConnectivity)
      let error = ConnectivityError.genericErrorCode(999)

      #expect(error.errorDescription == "Connectivity error: 999")
      #expect(
        error.failureReason == "An unexpected error occurred during the connectivity operation."
      )
      #expect(
        error.recoverySuggestion
          == "Check the underlying error for more details and try the operation again."
      )
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  @Test("Generic error code shows different codes in description")
  func genericErrorCodeVariations() {
    #if canImport(WatchConnectivity)
      let error1 = ConnectivityError.genericErrorCode(100)
      let error2 = ConnectivityError.genericErrorCode(200)

      #expect(error1.errorDescription == "Connectivity error: 100")
      #expect(error2.errorDescription == "Connectivity error: 200")

      // Failure reason and recovery suggestion should be the same
      #expect(error1.failureReason == error2.failureReason)
      #expect(error1.recoverySuggestion == error2.recoverySuggestion)
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }

  // MARK: - All Errors Have Complete Localization

  @Test("All non-generic errors have non-nil localization")
  func allErrorsHaveLocalization() {
    #if canImport(WatchConnectivity)
      let allErrors: [ConnectivityError] = [
        .sessionNotSupported,
        .sessionNotActivated,
        .sessionInactive,
        .deviceNotPaired,
        .companionAppNotInstalled,
        .notReachable,
        .messageReplyFailed,
        .messageReplyTimedOut,
        .invalidParameter,
        .payloadTooLarge,
        .payloadUnsupportedTypes,
        .transferTimedOut,
        .insufficientSpace,
        .fileNotAccessible,
        .sessionMissingDelegate,
        .fileAccessDenied,
        .deliveryFailed,
        .watchOnlyApp,
      ]

      for error in allErrors {
        #expect(error.errorDescription != nil, "Missing errorDescription for \(error)")
        #expect(error.failureReason != nil, "Missing failureReason for \(error)")
        #expect(error.recoverySuggestion != nil, "Missing recoverySuggestion for \(error)")

        // Ensure strings are not empty
        #expect(!error.errorDescription!.isEmpty, "Empty errorDescription for \(error)")
        #expect(!error.failureReason!.isEmpty, "Empty failureReason for \(error)")
        #expect(!error.recoverySuggestion!.isEmpty, "Empty recoverySuggestion for \(error)")
      }
    #else
      Issue.record("WatchConnectivity not available on this platform")
    #endif
  }
}
