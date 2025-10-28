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
  let isReachable: Bool

  /// WatchConnectivity session activation state
  let activationState: String

  /// Timestamp of last status update
  let lastUpdate: Date

  /// Creates a new connection status view.
  ///
  /// - Parameters:
  ///   - isReachable: Whether counterpart is reachable for sendMessage
  ///   - activationState: Activation state string (e.g., "Activated", "Not Activated")
  ///   - lastUpdate: When status was last updated
  public init(
    isReachable: Bool,
    activationState: String,
    lastUpdate: Date
  ) {
    self.isReachable = isReachable
    self.activationState = activationState
    self.lastUpdate = lastUpdate
  }

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

  private var backgroundColor: Color {
    #if os(iOS)
      Color(uiColor: .systemGray6)
    #elseif os(macOS)
      Color(nsColor: .controlBackgroundColor)
    #else
    Color(uiColor: UIColor.darkGray)
    #endif
  }

  public var body: some View {
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

      #if os(watchOS)
      // Compact watchOS layout - just symbols and time
      HStack(spacing: 4) {
        // Session state as symbol
        Image(systemName: activationState.lowercased() == "activated" ? "circle.fill" : "circle")
          .font(.system(size: 6))
          .foregroundColor(activationState.lowercased() == "activated" ? .green : .secondary)

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
    .padding(.horizontal, 12)
    #if os(watchOS)
    .padding(.vertical, 4)
    #else
    .padding(.vertical, 8)
    #endif
    .background(
      Rectangle()
        .fill(backgroundColor)
    )
  }
}

@available(iOS 17.0, watchOS 10.0, *)
#Preview("Connection States") {
  VStack(spacing: 0) {
    // Reachable and activated
    ConnectionStatusView(
      isReachable: true,
      activationState: "Activated",
      lastUpdate: Date()
    )

    Divider()

    // Not reachable but activated
    ConnectionStatusView(
      isReachable: false,
      activationState: "Activated",
      lastUpdate: Date().addingTimeInterval(-120)
    )

    Divider()

    // Not activated
    ConnectionStatusView(
      isReachable: false,
      activationState: "Not Activated",
      lastUpdate: Date().addingTimeInterval(-300)
    )

    Divider()

    // Inactive
    ConnectionStatusView(
      isReachable: false,
      activationState: "Inactive",
      lastUpdate: Date().addingTimeInterval(-60)
    )
  }
}
