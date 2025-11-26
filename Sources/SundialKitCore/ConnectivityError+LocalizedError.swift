//
// ConnectivityError+LocalizedError.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation

extension ConnectivityError: LocalizedError {
  // MARK: - Error Information Dictionary

  private static let errorInfo: [ConnectivityError: LocalizedInfo] = [
    .sessionNotSupported: .sessionNotSupported,
    .sessionNotActivated: .sessionNotActivated,
    .sessionInactive: .sessionInactive,
    .deviceNotPaired: .deviceNotPaired,
    .companionAppNotInstalled: .companionAppNotInstalled,
    .notReachable: .notReachable,
    .messageReplyFailed: .messageReplyFailed,
    .messageReplyTimedOut: .messageReplyTimedOut,
    .invalidParameter: .invalidParameter,
    .payloadTooLarge: .payloadTooLarge,
    .payloadUnsupportedTypes: .payloadUnsupportedTypes,
    .transferTimedOut: .transferTimedOut,
    .insufficientSpace: .insufficientSpace,
    .fileNotAccessible: .fileNotAccessible,
    .sessionMissingDelegate: .sessionMissingDelegate,
    .fileAccessDenied: .fileAccessDenied,
    .deliveryFailed: .deliveryFailed,
    .watchOnlyApp: .watchOnlyApp,
  ]

  // MARK: - LocalizedError Properties

  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    guard case .genericErrorCode(let code) = self else {
      let info = Self.errorInfo[self]
      assert(info != nil, "Missing error info for \(self)")
      return info?.description
    }
    return "Connectivity error: \(code)"
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    guard case .genericErrorCode = self else {
      let info = Self.errorInfo[self]
      assert(info != nil, "Missing error info for \(self)")
      return info?.reason
    }
    return "An unexpected error occurred during the connectivity operation."
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    guard case .genericErrorCode = self else {
      let info = Self.errorInfo[self]
      assert(info != nil, "Missing error info for \(self)")
      return info?.suggestion
    }
    return "Check the underlying error for more details and try the operation again."
  }
}
