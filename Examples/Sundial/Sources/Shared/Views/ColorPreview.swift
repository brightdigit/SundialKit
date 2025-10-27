//
//  ColorPreview.swift
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

/// Displays a color circle with optional metadata (timestamp, source).
///
/// Used to show sent and received colors in the Message Lab and Protocol Comparison tabs.
///
/// Example usage:
/// ```swift
/// ColorPreview(
///   color: .blue,
///   timestamp: Date(),
///   source: "iPhone",
///   size: 80
/// )
/// ```
public struct ColorPreview: View {
  /// The color to display
  let color: Color

  /// Optional timestamp when color was sent/received
  let timestamp: Date?

  /// Optional source device (e.g., "iPhone", "Watch")
  let source: String?

  /// Size of the color circle (default: 60)
  let size: CGFloat

  /// Creates a new color preview.
  ///
  /// - Parameters:
  ///   - color: The color to display
  ///   - timestamp: When the color was sent/received
  ///   - source: Source device name
  ///   - size: Diameter of the color circle
  public init(
    color: Color,
    timestamp: Date? = nil,
    source: String? = nil,
    size: CGFloat = 60
  ) {
    self.color = color
    self.timestamp = timestamp
    self.source = source
    self.size = size
  }

  public var body: some View {
    VStack(spacing: 8) {
      // Color circle with border
      Circle()
        .fill(color)
        .frame(width: size, height: size)
        .overlay(
          Circle()
            .stroke(Color.primary.opacity(0.2), lineWidth: 2)
        )
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)

      // Metadata
      VStack(spacing: 2) {
        if let source = source {
          Text(source)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.primary)
        }

        if let timestamp = timestamp {
          Text(timestamp, style: .time)
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
    }
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  struct ColorPreview_Previews: PreviewProvider {
    static var previews: some View {
      VStack(spacing: 24) {
        HStack(spacing: 24) {
          ColorPreview(
            color: .red,
            timestamp: Date(),
            source: "iPhone"
          )

          ColorPreview(
            color: .blue,
            timestamp: Date().addingTimeInterval(-30),
            source: "Watch"
          )

          ColorPreview(
            color: .green,
            size: 80
          )
        }

        HStack(spacing: 16) {
          ColorPreview(
            color: .purple,
            timestamp: Date(),
            size: 40
          )

          ColorPreview(
            color: .orange,
            timestamp: Date(),
            size: 40
          )

          ColorPreview(
            color: .pink,
            timestamp: Date(),
            size: 40
          )
        }
      }
      .padding()
      .previewLayout(.sizeThatFits)
    }
  }
#endif
