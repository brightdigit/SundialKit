//
// ConnectivityError.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation

#if canImport(WatchConnectivity)
  public import WatchConnectivity
#endif

/// Errors that can occur during WatchConnectivity operations.
///
/// Provides detailed error information for failures in establishing connectivity
/// sessions, sending messages, and managing data transfer between iOS and watchOS.
/// Conforms to `Error`, `Sendable`, `Hashable`, and `LocalizedError`.
public enum ConnectivityError: Error, Sendable, Hashable {
  // MARK: - Session Errors

  /// WatchConnectivity session is not supported on this device.
  case sessionNotSupported

  /// The WatchConnectivity session has not been activated.
  case sessionNotActivated

  /// The WatchConnectivity session is inactive.
  case sessionInactive

  // MARK: - Device Errors

  /// No companion device is paired.
  case deviceNotPaired

  /// The companion app is not installed on the paired device.
  case companionAppNotInstalled

  /// The counterpart device is not currently reachable.
  case notReachable

  // MARK: - Messaging Errors

  /// The message reply operation failed.
  case messageReplyFailed

  /// The message reply timed out.
  case messageReplyTimedOut

  /// Invalid parameter provided to the connectivity operation.
  case invalidParameter

  /// The message payload exceeds the maximum size limit.
  case payloadTooLarge

  /// The message payload contains unsupported types.
  case payloadUnsupportedTypes

  // MARK: - Transfer Errors

  /// The data transfer operation timed out.
  case transferTimedOut

  /// Insufficient storage space for the transfer.
  case insufficientSpace

  /// The file is not accessible for transfer.
  case fileNotAccessible

  // MARK: - Session Configuration Errors

  /// The WatchConnectivity session is missing a required delegate.
  case sessionMissingDelegate

  /// Access to the file was denied by the system.
  case fileAccessDenied

  /// Message delivery failed.
  case deliveryFailed

  /// The app is watch-only and cannot use certain connectivity features.
  case watchOnlyApp

  /// An unknown or generic connectivity error occurred.
  case genericErrorCode(Int)

  // MARK: - WCError Mapping

  #if canImport(WatchConnectivity)
    /// Creates a `ConnectivityError` from a `WCError`.
    ///
    /// Maps WatchConnectivity framework errors to typed cases.
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

    /// Creates a `ConnectivityError` from a WatchConnectivity framework error.
    ///
    /// - Parameter wcError: The `WCError` to convert
    public init(wcError: WCError) {
      guard let mapped = Self.wcErrorMapping[wcError.code] else {
        self = .genericErrorCode(wcError.code.rawValue)
        return
      }
      self = mapped
    }
  #endif
}
