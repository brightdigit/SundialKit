//
//  TransportBadge.swift
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

/// Visual indicator for WatchConnectivity transport methods.
///
/// Displays an icon, name, and color-coded badge for each transport method.
/// Active state shown with stronger visual emphasis.
///
/// Example usage:
/// ```swift
/// TransportBadge(
///   method: .sendMessage,
///   isActive: true
/// )
/// ```
public struct TransportBadge: View {
  /// The transport method to display
  let method: TransportMethod

  /// Whether this method is currently active/selected
  let isActive: Bool

  /// Creates a new transport method badge.
  ///
  /// - Parameters:
  ///   - method: The transport method
  ///   - isActive: Whether the method is currently active
  public init(method: TransportMethod, isActive: Bool) {
    self.method = method
    self.isActive = isActive
  }

  private var grayBackgroundColor: Color {
    #if os(iOS) || os(watchOS)
      Color(uiColor: .systemGray6)
    #elseif os(macOS)
      Color(nsColor: .controlBackgroundColor)
    #else
      Color.gray.opacity(0.2)
    #endif
  }

  public var body: some View {
    HStack(spacing: 6) {
      // Icon
      Image(systemName: method.icon)
        .font(.caption)

      // Name
      Text(method.displayName)
        .font(.caption)
        .fontWeight(isActive ? .semibold : .regular)
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .fill(isActive ? method.color.opacity(0.2) : grayBackgroundColor)
    )
    .overlay(
      Capsule()
        .strokeBorder(
          isActive ? method.color : Color.clear,
          lineWidth: isActive ? 1.5 : 0
        )
    )
    .foregroundColor(isActive ? method.color : .secondary)
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  struct TransportBadge_Previews: PreviewProvider {
    static var previews: some View {
      VStack(spacing: 16) {
        // Active states
        HStack(spacing: 12) {
          TransportBadge(method: .sendMessage, isActive: true)
          TransportBadge(method: .sendMessageData, isActive: true)
          TransportBadge(method: .updateApplicationContext, isActive: true)
        }

        // Inactive states
        HStack(spacing: 12) {
          TransportBadge(method: .sendMessage, isActive: false)
          TransportBadge(method: .sendMessageData, isActive: false)
          TransportBadge(method: .updateApplicationContext, isActive: false)
        }

        // Mixed states
        VStack(alignment: .leading, spacing: 8) {
          Text("Select Transport Method:")
            .font(.caption)
            .foregroundColor(.secondary)

          HStack(spacing: 8) {
            TransportBadge(method: .sendMessage, isActive: true)
            TransportBadge(method: .sendMessageData, isActive: false)
            TransportBadge(method: .updateApplicationContext, isActive: false)
          }
        }
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }
#endif
