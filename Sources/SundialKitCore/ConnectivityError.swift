//
//  ConnectivityError.swift
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

public import Foundation

#if canImport(WatchConnectivity)
  @preconcurrency import WatchConnectivity
#endif

/// Errors that can occur during WatchConnectivity operations.
///
/// `ConnectivityError` provides detailed error information for failures in
/// establishing connectivity sessions, sending messages, and managing data
/// transfer between iOS and watchOS devices.
///
/// All cases conform to `Error`, `Sendable`, and `LocalizedError` for
/// comprehensive error handling and reporting.
///
/// ## Topics
///
/// ### Session Errors
/// - ``sessionNotSupported``
/// - ``sessionNotActivated``
/// - ``sessionInactive``
///
/// ### Device Errors
/// - ``deviceNotPaired``
/// - ``companionAppNotInstalled``
/// - ``notReachable``
///
/// ### Messaging Errors
/// - ``messageReplyFailed``
/// - ``messageReplyTimedOut``
/// - ``invalidParameter``
/// - ``payloadTooLarge``
/// - ``payloadUnsupportedTypes``
///
/// ### Transfer Errors
/// - ``transferTimedOut``
/// - ``insufficientSpace``
/// - ``fileNotAccessible``
///
/// ### WCError Mapping
/// - ``init(wcError:)``
///
/// ## Example Usage
///
/// ```swift
/// do {
///     try connectivityManager.activate()
/// } catch let error as ConnectivityError {
///     switch error {
///     case .sessionNotSupported:
///         print("WatchConnectivity is not supported on this device")
///     case .notReachable:
///         print("Counterpart device is not reachable")
///     case .messageReplyTimedOut:
///         print("Message reply timed out")
///     default:
///         print("Connectivity error: \(error.localizedDescription)")
///     }
/// }
/// ```
public enum ConnectivityError: Error, Sendable {
  // MARK: - Session Errors

  /// WatchConnectivity session is not supported on this device.
  ///
  /// This error occurs when attempting to use WatchConnectivity on devices
  /// that don't support it, such as iPad or Mac.
  case sessionNotSupported

  /// The WatchConnectivity session has not been activated.
  ///
  /// Call `activate()` on the connectivity manager before attempting to
  /// send or receive messages.
  case sessionNotActivated

  /// The WatchConnectivity session is inactive.
  ///
  /// The session is transitioning to a deactivated state and cannot
  /// currently send or receive messages.
  case sessionInactive

  // MARK: - Device Errors

  /// No companion device is paired.
  ///
  /// - On iOS: No Apple Watch is paired with this iPhone
  /// - On watchOS: No iPhone is paired with this Apple Watch
  case deviceNotPaired

  /// The companion app is not installed on the paired device.
  ///
  /// - On iOS: The watchOS app is not installed
  /// - On watchOS: The iOS app is not installed
  case companionAppNotInstalled

  /// The counterpart device is not currently reachable.
  ///
  /// The device may be out of Bluetooth range, the app may not be running,
  /// or the device may be powered off.
  case notReachable

  // MARK: - Messaging Errors

  /// The message reply operation failed.
  ///
  /// The counterpart device received the message but encountered an error
  /// while processing it or generating a reply.
  case messageReplyFailed

  /// The message reply timed out.
  ///
  /// The counterpart device did not respond within the expected timeframe.
  case messageReplyTimedOut

  /// Invalid parameter provided to the connectivity operation.
  ///
  /// Check that message dictionaries contain only property list types
  /// and that all required parameters are provided.
  case invalidParameter

  /// The message payload exceeds the maximum size limit.
  ///
  /// WatchConnectivity has limits on message and data transfer sizes.
  /// Consider breaking large data into smaller chunks or using file transfers.
  case payloadTooLarge

  /// The message payload contains unsupported types.
  ///
  /// WatchConnectivity messages must contain only property list types:
  /// String, Number, Date, Data, Array, and Dictionary.
  case payloadUnsupportedTypes

  // MARK: - Transfer Errors

  /// The data transfer operation timed out.
  ///
  /// The transfer did not complete within the expected timeframe.
  case transferTimedOut

  /// Insufficient storage space for the transfer.
  ///
  /// The receiving device does not have enough available storage to
  /// complete the data transfer.
  case insufficientSpace

  /// The file is not accessible for transfer.
  ///
  /// The specified file cannot be read or does not exist at the provided path.
  case fileNotAccessible

  /// An unknown or generic connectivity error occurred.
  ///
  /// - Parameter underlyingError: The original system error, if available.
  case genericError(any Error)

  // MARK: - WCError Mapping

  #if canImport(WatchConnectivity)
    /// Creates a `ConnectivityError` from a `WCError`.
    ///
    /// This initializer maps WatchConnectivity framework errors to typed
    /// `ConnectivityError` cases for consistent error handling.
    ///
    /// - Parameter wcError: The `WCError` from WatchConnectivity framework.
    ///
    /// ## Example
    ///
    /// ```swift
    /// func handleWCError(_ error: Error) {
    ///     if let wcError = error as? WCError {
    ///         let connectivityError = ConnectivityError(wcError: wcError)
    ///         print("Mapped error: \(connectivityError)")
    ///     }
    /// }
    /// ```
    public init(wcError: WCError) {
      switch wcError.code {
      case .sessionNotSupported:
        self = .sessionNotSupported
      case .sessionNotActivated:
        self = .sessionNotActivated
      case .sessionInactive:
        self = .sessionInactive
      case .deviceNotPaired:
        self = .deviceNotPaired
      case .watchAppNotInstalled:
        self = .companionAppNotInstalled
      case .notReachable:
        self = .notReachable
      case .invalidParameter:
        self = .invalidParameter
      case .payloadTooLarge:
        self = .payloadTooLarge
      case .payloadUnsupportedTypes:
        self = .payloadUnsupportedTypes
      case .messageReplyFailed:
        self = .messageReplyFailed
      case .messageReplyTimedOut:
        self = .messageReplyTimedOut
      case .transferTimedOut:
        self = .transferTimedOut
      case .insufficientSpace:
        self = .insufficientSpace
      case .fileAccessible:
        self = .fileNotAccessible
      case .genericError:
        self = .genericError(wcError)
      @unknown default:
        self = .genericError(wcError)
      }
    }
  #endif
}

// MARK: - LocalizedError Conformance

extension ConnectivityError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity is not supported on this device."
    case .sessionNotActivated:
      return "The connectivity session has not been activated."
    case .sessionInactive:
      return "The connectivity session is inactive."
    case .deviceNotPaired:
      return "No companion device is paired."
    case .companionAppNotInstalled:
      return "The companion app is not installed on the paired device."
    case .notReachable:
      return "The counterpart device is not currently reachable."
    case .messageReplyFailed:
      return "The message reply operation failed."
    case .messageReplyTimedOut:
      return "The message reply timed out."
    case .invalidParameter:
      return "Invalid parameter provided to connectivity operation."
    case .payloadTooLarge:
      return "The message payload exceeds the maximum size limit."
    case .payloadUnsupportedTypes:
      return "The message payload contains unsupported types."
    case .transferTimedOut:
      return "The data transfer operation timed out."
    case .insufficientSpace:
      return "Insufficient storage space for the transfer."
    case .fileNotAccessible:
      return "The file is not accessible for transfer."
    case .genericError(let error):
      return "Connectivity error: \(error.localizedDescription)"
    }
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity is only available on iPhone and Apple Watch devices."
    case .sessionNotActivated:
      return "The session must be activated before sending or receiving messages."
    case .sessionInactive:
      return "The session is transitioning to a deactivated state."
    case .deviceNotPaired:
      return "This device is not paired with a companion device."
    case .companionAppNotInstalled:
      return "The corresponding app is not installed on the paired device."
    case .notReachable:
      return "The device may be out of range, powered off, or the app may not be running."
    case .messageReplyFailed:
      return "The counterpart encountered an error while processing the message."
    case .messageReplyTimedOut:
      return "The counterpart did not respond within the timeout period."
    case .invalidParameter:
      return "One or more parameters do not meet the required format or constraints."
    case .payloadTooLarge:
      return "The data exceeds WatchConnectivity's transfer size limits."
    case .payloadUnsupportedTypes:
      return "The message contains types that cannot be transmitted via WatchConnectivity."
    case .transferTimedOut:
      return "The transfer did not complete within the expected time."
    case .insufficientSpace:
      return "The receiving device does not have enough available storage."
    case .fileNotAccessible:
      return "The specified file cannot be accessed or does not exist."
    case .genericError:
      return "An unexpected error occurred during the connectivity operation."
    }
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity features are only available on compatible devices."
    case .sessionNotActivated:
      return "Call activate() on the connectivity manager before using messaging features."
    case .sessionInactive:
      return "Wait for the session to become active again or reactivate it."
    case .deviceNotPaired:
      return "Pair an Apple Watch with this iPhone or an iPhone with this Apple Watch."
    case .companionAppNotInstalled:
      return "Install the companion app on the paired device."
    case .notReachable:
      return "Ensure both devices are powered on, within range, and the app is running on the counterpart."
    case .messageReplyFailed:
      return "Check the message format and try again. The counterpart may need to handle the message differently."
    case .messageReplyTimedOut:
      return "Try sending the message again. Consider checking if the counterpart is responsive."
    case .invalidParameter:
      return "Ensure all message data uses property list types (String, Number, Date, Data, Array, Dictionary)."
    case .payloadTooLarge:
      return "Reduce the message size or split the data into multiple smaller messages."
    case .payloadUnsupportedTypes:
      return "Use only property list types in message dictionaries."
    case .transferTimedOut:
      return "Check network connectivity and try the transfer again."
    case .insufficientSpace:
      return "Free up storage space on the receiving device and retry the transfer."
    case .fileNotAccessible:
      return "Verify the file path is correct and the file exists."
    case .genericError:
      return "Check the underlying error for more details and try the operation again."
    }
  }
}
