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
  public let method: TransportMethod

  /// Whether this method is currently active/selected
  public let isActive: Bool

  public var body: some View {
    HStack(spacing: 6) {
      // Icon
      Image(systemName: method.icon)
        .font(.caption)

      #if !os(watchOS)
      // Name
      Text(method.displayName)
        .font(.caption)
        .fontWeight(isActive ? .semibold : .regular)
      #endif
    }
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(
      Capsule()
        .fill(isActive ? method.color.opacity(0.2) : Color.grayBackgroundColor)
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

  /// Creates a new transport method badge.
  ///
  /// - Parameters:
  ///   - method: The transport method
  ///   - isActive: Whether the method is currently active
  public init(method: TransportMethod, isActive: Bool) {
    self.method = method
    self.isActive = isActive
  }
}
