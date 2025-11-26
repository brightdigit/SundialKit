//
// SundialError.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation

/// Legacy errors thrown by the framework.
///
/// - Deprecated: Use ``ConnectivityError`` for connectivity-related errors,
///   ``NetworkError`` for network monitoring errors, or ``SerializationError``
///   for message encoding/decoding errors.
///
/// This enum is maintained for backward compatibility with SundialKit 1.x.
/// New code should use the more specific error types.
@available(
  *, deprecated, message: "Use ConnectivityError, NetworkError, or SerializationError instead"
)
public enum SundialError: Error, Sendable {
  /// If WCSession.isSupported() returns false, this error is thrown.
  ///
  /// - Deprecated: Use ``ConnectivityError/sessionNotSupported`` instead.
  case sessionNotSupported

  /// When there is no companion device (i.e. iPhone or Apple Watch).
  ///
  /// - Deprecated: Use ``ConnectivityError/deviceNotPaired`` or
  ///   ``ConnectivityError/companionAppNotInstalled`` instead.
  case missingCompanion
}

// MARK: - LocalizedError Conformance

extension SundialError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity is not supported on this device."
    case .missingCompanion:
      return "No companion device is available."
    }
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity is only available on iPhone and Apple Watch devices."
    case .missingCompanion:
      return
        "This device is not paired with a companion device or the companion app is not installed."
    }
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    switch self {
    case .sessionNotSupported:
      return "WatchConnectivity features are only available on compatible devices."
    case .missingCompanion:
      return "Ensure devices are paired and the companion app is installed."
    }
  }
}

// MARK: - Migration Helpers

extension SundialError {
  /// Converts this legacy error to the appropriate modern error type.
  ///
  /// - Returns: A ``ConnectivityError`` equivalent to this error.
  public func toConnectivityError() -> ConnectivityError {
    switch self {
    case .sessionNotSupported:
      return .sessionNotSupported
    case .missingCompanion:
      return .deviceNotPaired
    }
  }
}
