//
//  NetworkError.swift
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

/// Errors that can occur during network monitoring operations.
///
/// `NetworkError` provides detailed information about failures in network
/// monitoring, path status detection, and connectivity verification.
///
/// All cases conform to `Error`, `Sendable`, and `LocalizedError` for
/// comprehensive error handling and reporting.
///
/// ## Topics
///
/// ### Error Cases
/// - ``monitoringUnavailable``
/// - ``pathUpdateFailed``
/// - ``pingTimeout``
/// - ``pingFailed(_:)``
/// - ``invalidConfiguration``
///
/// ## Example Usage
///
/// ```swift
/// do {
///     try networkMonitor.start(queue: .global())
/// } catch let error as NetworkError {
///     switch error {
///     case .monitoringUnavailable:
///         print("Network monitoring is not available on this platform")
///     case .pathUpdateFailed:
///         print("Failed to update network path status")
///     case .pingTimeout:
///         print("Network ping timed out")
///     case .pingFailed(let reason):
///         print("Ping failed: \(reason)")
///     case .invalidConfiguration:
///         print("Invalid monitoring configuration")
///     }
/// }
/// ```
public enum NetworkError: Error, Sendable {
  /// Network monitoring is not available on the current platform or configuration.
  ///
  /// This error occurs when attempting to use network monitoring features
  /// on platforms that don't support them or when required frameworks are unavailable.
  case monitoringUnavailable

  /// Failed to update the network path status.
  ///
  /// This error indicates a failure in retrieving or processing network path
  /// information from the underlying system APIs.
  case pathUpdateFailed

  /// Network connectivity verification (ping) timed out.
  ///
  /// The network ping operation did not complete within the expected timeframe,
  /// indicating potential connectivity issues or network congestion.
  case pingTimeout

  /// Network connectivity verification failed with a specific reason.
  ///
  /// - Parameter reason: A description of why the ping operation failed.
  case pingFailed(String)

  /// The network monitoring configuration is invalid.
  ///
  /// This error occurs when monitoring is initialized with invalid parameters,
  /// such as an invalid queue or conflicting configuration options.
  case invalidConfiguration
}

// MARK: - LocalizedError Conformance

extension NetworkError: LocalizedError {
  /// A localized message describing what error occurred.
  public var errorDescription: String? {
    switch self {
    case .monitoringUnavailable:
      return "Network monitoring is not available on this platform or configuration."
    case .pathUpdateFailed:
      return "Failed to update network path status."
    case .pingTimeout:
      return "Network connectivity verification timed out."
    case .pingFailed(let reason):
      return "Network ping failed: \(reason)"
    case .invalidConfiguration:
      return "Invalid network monitoring configuration."
    }
  }

  /// A localized message describing the reason for the failure.
  public var failureReason: String? {
    switch self {
    case .monitoringUnavailable:
      return "The current platform or system configuration does not support network monitoring."
    case .pathUpdateFailed:
      return "The system was unable to provide network path information."
    case .pingTimeout:
      return "The network did not respond within the expected time limit."
    case .pingFailed:
      return "The network connectivity verification encountered an error."
    case .invalidConfiguration:
      return "The provided monitoring configuration contains invalid parameters."
    }
  }

  /// A localized message describing how to recover from the failure.
  public var recoverySuggestion: String? {
    switch self {
    case .monitoringUnavailable:
      return "Check platform requirements and ensure network monitoring is supported on this device."
    case .pathUpdateFailed:
      return "Try restarting network monitoring or check system network settings."
    case .pingTimeout:
      return "Check network connectivity and try again. Consider increasing the timeout interval."
    case .pingFailed:
      return "Verify network configuration and ensure the target is reachable."
    case .invalidConfiguration:
      return "Review monitoring configuration parameters and ensure all required values are provided."
    }
  }
}
