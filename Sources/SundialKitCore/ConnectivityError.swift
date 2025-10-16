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
  public import WatchConnectivity
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
/// - ``fileAccessDenied``
///
/// ### Session Configuration Errors
/// - ``sessionMissingDelegate``
/// - ``deliveryFailed``
/// - ``watchOnlyApp``
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
public enum ConnectivityError: Error, Sendable, Hashable {
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

  // MARK: - Session Configuration Errors

  /// The WatchConnectivity session is missing a required delegate.
  ///
  /// A delegate must be set on the session before activation.
  case sessionMissingDelegate

  /// Access to the file was denied by the system.
  ///
  /// The app does not have permission to access the requested file.
  case fileAccessDenied

  /// Message delivery failed.
  ///
  /// The message could not be delivered to the counterpart device.
  case deliveryFailed

  /// The app is watch-only and cannot use certain connectivity features.
  ///
  /// Some WatchConnectivity features require a companion iOS app.
  case watchOnlyApp

  /// An unknown or generic connectivity error occurred.
  ///
  /// - Parameter underlyingError: The original system error, if available.
  case genericErrorCode(Int)

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

    private static let wcErrorMapping: [WCError.Code: ConnectivityError] = [
      .sessionNotSupported: .sessionNotSupported,
      .sessionNotActivated: .sessionNotActivated,
      .sessionInactive: .sessionInactive,
      .deviceNotPaired: .deviceNotPaired,
      .watchAppNotInstalled: .companionAppNotInstalled,
      .notReachable: .notReachable,
      .invalidParameter: .invalidParameter,
      .payloadTooLarge: .payloadTooLarge,
      .payloadUnsupportedTypes: .payloadUnsupportedTypes,
      .messageReplyFailed: .messageReplyFailed,
      .messageReplyTimedOut: .messageReplyTimedOut,
      .transferTimedOut: .transferTimedOut,
      .insufficientSpace: .insufficientSpace,
      .sessionMissingDelegate: .sessionMissingDelegate,
      .fileAccessDenied: .fileAccessDenied,
      .deliveryFailed: .deliveryFailed,
      .companionAppNotInstalled: .companionAppNotInstalled,
      .watchOnlyApp: .watchOnlyApp,
    ]

    public init(wcError: WCError) {
      guard let mapped = Self.wcErrorMapping[wcError.code] else {
        self = .genericErrorCode(wcError.code.rawValue)
        return
      }
      self = mapped
    }
  #endif
}

// MARK: - Error Information Structure

// MARK: - LocalizedError Conformance
