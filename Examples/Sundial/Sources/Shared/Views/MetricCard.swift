//
//  MetricCard.swift
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

/// Reusable card component for displaying key metrics with icon, title, value, and subtitle.
///
/// Used throughout the Sundial demo to display statistics like RTT, payload sizes,
/// success rates, and encoding/decoding times.
///
/// Example usage:
/// ```swift
/// MetricCard(
///   title: "Round Trip Time",
///   value: "23.5 ms",
///   subtitle: "Last message",
///   icon: "clock.arrow.circlepath",
///   color: .blue
/// )
/// ```
public struct MetricCard: View {
  /// The metric name displayed at the top
  let title: String

  /// The primary value to display (formatted by caller)
  let value: String

  /// Optional secondary information below the value
  let subtitle: String?

  /// SF Symbol name for the icon
  let icon: String

  /// Accent color for the icon and highlights
  let color: Color

  /// Creates a new metric card.
  ///
  /// - Parameters:
  ///   - title: The metric name (e.g., "Round Trip Time")
  ///   - value: The formatted value to display (e.g., "23.5 ms")
  ///   - subtitle: Optional context (e.g., "Last message")
  ///   - icon: SF Symbol name
  ///   - color: Accent color for visual emphasis
  public init(
    title: String,
    value: String,
    subtitle: String? = nil,
    icon: String,
    color: Color
  ) {
    self.title = title
    self.value = value
    self.subtitle = subtitle
    self.icon = icon
    self.color = color
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      // Header with icon and title
      HStack {
        Image(systemName: icon)
          .foregroundColor(color)
          .font(.title3)

        Text(title)
          .font(.caption)
          .foregroundColor(.secondary)

        Spacer()
      }

      // Large value display
      Text(value)
        .font(.system(.title2, design: .rounded))
        .fontWeight(.semibold)
        .foregroundColor(.primary)

      // Optional subtitle
      if let subtitle = subtitle {
        Text(subtitle)
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color(.systemBackground))
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    )
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  struct MetricCard_Previews: PreviewProvider {
    static var previews: some View {
      VStack(spacing: 16) {
        MetricCard(
          title: "Round Trip Time",
          value: "23.5 ms",
          subtitle: "Last message",
          icon: "clock.arrow.circlepath",
          color: .blue
        )

        MetricCard(
          title: "Payload Size",
          value: "1.2 KB",
          subtitle: "Compressed",
          icon: "doc.zipper",
          color: .green
        )

        MetricCard(
          title: "Success Rate",
          value: "98.5%",
          subtitle: "Last 100 messages",
          icon: "checkmark.circle.fill",
          color: .green
        )

        MetricCard(
          title: "Encode Time",
          value: "0.8 ms",
          icon: "arrow.up.doc",
          color: .orange
        )
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }
#endif
