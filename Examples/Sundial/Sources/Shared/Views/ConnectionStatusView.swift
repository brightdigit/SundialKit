//
//  ConnectionStatusView.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
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

import SwiftUI

/// Compact status footer showing network and connectivity health.
///
/// Displays reachability state, WatchConnectivity activation state, and last update time.
/// Color-coded for quick visual reference of connection health.
///
/// Example usage:
/// ```swift
/// ConnectionStatusView(
///   isReachable: true,
///   activationState: "Activated",
///   lastUpdate: Date()
/// )
/// ```
public struct ConnectionStatusView: View {
  /// Whether the counterpart device is reachable
  public let isReachable: Bool

  /// WatchConnectivity session activation state
  public let activationState: String

  /// Timestamp of last status update
  public let lastUpdate: Date

  /// Whether devices are paired
  public let isPaired: Bool?

  /// Whether companion app is installed
  public let isPairedAppInstalled: Bool?

  private var statusColor: Color {
    if activationState.lowercased() != "activated" {
      return .red
    }
    return isReachable ? .green : .orange
  }

  private var statusIcon: String {
    if activationState.lowercased() != "activated" {
      return "xmark.circle.fill"
    }
    return isReachable ? "checkmark.circle.fill" : "exclamationmark.triangle.fill"
  }

  private var statusText: String {
    if activationState.lowercased() != "activated" {
      return "Not Connected"
    }
    return isReachable ? "Reachable" : "Not Reachable"
  }

  public var body: some View {
    VStack(spacing: 0) {
      mainStatusRow

      // Diagnostic row (only on non-watchOS when available)
      #if !os(watchOS)
        diagnosticRow
      #endif
    }
    .background(
      Rectangle()
        .fill(Color.grayBackgroundColor)
    )
  }

  private var mainStatusRow: some View {
    HStack(spacing: 12) {
      // Status indicator
      HStack(spacing: 6) {
        Image(systemName: statusIcon)
          .font(.caption)
          .foregroundColor(statusColor)
        #if !os(watchOS)
          Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
        #endif
      }

      Spacer()

      trailingStatus
    }
    .padding(.horizontal, 12)
    #if os(watchOS)
      .padding(.vertical, 4)
    #else
      .padding(.vertical, 8)
    #endif
  }

  @ViewBuilder
  private var trailingStatus: some View {
    #if os(watchOS)
      // Compact watchOS layout - just symbols and time
      let isActivated = activationState.lowercased() == "activated"
      HStack(spacing: 4) {
        // Session state as symbol
        Image(systemName: isActivated ? "circle.fill" : "circle")
          .font(.system(size: 6))
          .foregroundColor(isActivated ? .green : .secondary)

        // Last update (compact)
        Text(lastUpdate, style: .relative)
          .font(.system(size: 10))
          .foregroundColor(.secondary)
      }
    #else
      // Full layout for iOS/macOS
      // Session state
      Text(activationState)
        .font(.caption2)
        .foregroundColor(.secondary)

      // Last update
      Text(lastUpdate, style: .relative)
        .font(.caption2)
        .foregroundColor(.secondary)
    #endif
  }

  @ViewBuilder
  private var diagnosticRow: some View {
    if let isPaired = isPaired, let isPairedAppInstalled = isPairedAppInstalled {
      Divider()
        .background(Color.secondary.opacity(0.3))

      HStack(spacing: 12) {
        // Paired status
        HStack(spacing: 4) {
          Image(systemName: isPaired ? "link.circle.fill" : "link.circle")
            .font(.caption2)
            .foregroundColor(isPaired ? .green : .orange)
          Text("Paired")
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        // App installed status
        HStack(spacing: 4) {
          Image(
            systemName: isPairedAppInstalled ? "app.badge.checkmark.fill" : "app.badge"
          )
          .font(.caption2)
          .foregroundColor(isPairedAppInstalled ? .green : .red)
          Text("App Installed")
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
    }
  }

  /// Creates a new connection status view.
  ///
  /// - Parameters:
  ///   - isReachable: Whether counterpart is reachable for sendMessage
  ///   - activationState: Activation state string (e.g., "Activated", "Not Activated")
  ///   - lastUpdate: When status was last updated
  ///   - isPaired: Whether devices are paired (optional for backward compatibility)
  ///   - isPairedAppInstalled: Whether companion app is installed
  public init(
    isReachable: Bool,
    activationState: String,
    lastUpdate: Date,
    isPaired: Bool? = nil,
    isPairedAppInstalled: Bool? = nil
  ) {
    self.isReachable = isReachable
    self.activationState = activationState
    self.lastUpdate = lastUpdate
    self.isPaired = isPaired
    self.isPairedAppInstalled = isPairedAppInstalled
  }
}
