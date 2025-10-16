//
//  ConnectivityError+LocalizedError.swift
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
