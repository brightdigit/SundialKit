//
//  ConnectivityError+LocalizedInfo.swift
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

extension ConnectivityError {
  internal struct LocalizedInfo {
    // MARK: - Static Error Info Constants

    internal static let sessionNotSupported = LocalizedInfo(
      description: "WatchConnectivity is not supported on this device.",
      reason: "WatchConnectivity is only available on iPhone and Apple Watch devices.",
      suggestion: "WatchConnectivity features are only available on compatible devices."
    )

    internal static let sessionNotActivated = LocalizedInfo(
      description: "The connectivity session has not been activated.",
      reason: "The session must be activated before sending or receiving messages.",
      suggestion: "Call activate() on the connectivity manager before using messaging features."
    )

    internal static let sessionInactive = LocalizedInfo(
      description: "The connectivity session is inactive.",
      reason: "The session is transitioning to a deactivated state.",
      suggestion: "Wait for the session to become active again or reactivate it."
    )

    internal static let deviceNotPaired = LocalizedInfo(
      description: "No companion device is paired.",
      reason: "This device is not paired with a companion device.",
      suggestion: "Pair an Apple Watch with this iPhone or an iPhone with this Apple Watch."
    )

    internal static let companionAppNotInstalled = LocalizedInfo(
      description: "The companion app is not installed on the paired device.",
      reason: "The corresponding app is not installed on the paired device.",
      suggestion: "Install the companion app on the paired device."
    )

    internal static let notReachable = LocalizedInfo(
      description: "The counterpart device is not currently reachable.",
      reason: "The device may be out of range, powered off, or the app may not be running.",
      suggestion:
        "Ensure both devices are powered on, within range, and the app is running on the counterpart."
    )

    internal static let messageReplyFailed = LocalizedInfo(
      description: "The message reply operation failed.",
      reason: "The counterpart encountered an error while processing the message.",
      suggestion: """
        Check the message format and try again. \
        The counterpart may need to handle the message differently.
        """
    )

    internal static let messageReplyTimedOut = LocalizedInfo(
      description: "The message reply timed out.",
      reason: "The counterpart did not respond within the timeout period.",
      suggestion:
        "Try sending the message again. Consider checking if the counterpart is responsive."
    )

    internal static let invalidParameter = LocalizedInfo(
      description: "Invalid parameter provided to connectivity operation.",
      reason: "One or more parameters do not meet the required format or constraints.",
      suggestion:
        "Ensure all message data uses property list types (String, Number, Date, Data, Array, Dictionary)."
    )

    internal static let payloadTooLarge = LocalizedInfo(
      description: "The message payload exceeds the maximum size limit.",
      reason: "The data exceeds WatchConnectivity's transfer size limits.",
      suggestion: "Reduce the message size or split the data into multiple smaller messages."
    )

    internal static let payloadUnsupportedTypes = LocalizedInfo(
      description: "The message payload contains unsupported types.",
      reason: "The message contains types that cannot be transmitted via WatchConnectivity.",
      suggestion: "Use only property list types in message dictionaries."
    )

    internal static let transferTimedOut = LocalizedInfo(
      description: "The data transfer operation timed out.",
      reason: "The transfer did not complete within the expected time.",
      suggestion: "Check network connectivity and try the transfer again."
    )

    internal static let insufficientSpace = LocalizedInfo(
      description: "Insufficient storage space for the transfer.",
      reason: "The receiving device does not have enough available storage.",
      suggestion: "Free up storage space on the receiving device and retry the transfer."
    )

    internal static let fileNotAccessible = LocalizedInfo(
      description: "The file is not accessible for transfer.",
      reason: "The specified file cannot be accessed or does not exist.",
      suggestion: "Verify the file path is correct and the file exists."
    )

    internal static let sessionMissingDelegate = LocalizedInfo(
      description: "The connectivity session is missing a required delegate.",
      reason: "A delegate must be set on the WatchConnectivity session before it can be activated.",
      suggestion: "Set a delegate on the WatchConnectivity session before calling activate()."
    )

    internal static let fileAccessDenied = LocalizedInfo(
      description: "Access to the file was denied by the system.",
      reason: "The app does not have the necessary permissions to access this file.",
      suggestion: "Check the app's file access permissions and request access if needed."
    )

    internal static let deliveryFailed = LocalizedInfo(
      description: "Message delivery failed.",
      reason: "The message could not be delivered to the counterpart device.",
      suggestion: "Ensure the counterpart device is reachable and try sending the message again."
    )

    internal static let watchOnlyApp = LocalizedInfo(
      description: "The app is watch-only and cannot use certain connectivity features.",
      reason:
        "This is a watch-only app that requires a companion iOS app for full connectivity features.",
      suggestion: "Install the companion iOS app to enable full connectivity features."
    )

    // MARK: - Instance Properties

    internal let description: String
    internal let reason: String
    internal let suggestion: String

    // MARK: - Initialization

    private init(description: String, reason: String, suggestion: String) {
      self.description = description
      self.reason = reason
      self.suggestion = suggestion
    }
  }
}
