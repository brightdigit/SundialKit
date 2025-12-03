//
//  MessageHistoryRow.swift
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

/// Row item for message history list in Diagnostics tab.
///
/// Displays timestamp, transport method, payload size, round-trip time, and success status.
/// Color-coded by transport method for quick scanning.
///
/// Example usage:
/// ```swift
/// MessageHistoryRow(
///   timestamp: Date(),
///   method: .sendMessage,
///   size: 256,
///   rtt: 0.023,
///   success: true
/// )
/// ```
public struct MessageHistoryRow: View {
  /// When the message was sent
  let timestamp: Date

  /// Transport method used
  let method: TransportMethod

  /// Payload size in bytes
  let size: Int

  /// Round-trip time in seconds (nil if no reply expected)
  let rtt: TimeInterval?

  /// Whether the send was successful
  let success: Bool

  /// Creates a new message history row.
  ///
  /// - Parameters:
  ///   - timestamp: When message was sent
  ///   - method: Transport method used
  ///   - size: Payload size in bytes
  ///   - rtt: Round-trip time (nil for one-way messages)
  ///   - success: Whether send succeeded
  public init(
    timestamp: Date,
    method: TransportMethod,
    size: Int,
    rtt: TimeInterval?,
    success: Bool
  ) {
    self.timestamp = timestamp
    self.method = method
    self.size = size
    self.rtt = rtt
    self.success = success
  }

  private var sizeFormatted: String {
    let kb = Double(size) / 1024.0
    if kb < 1 {
      return "\(size) B"
    } else {
      return String(format: "%.1f KB", kb)
    }
  }

  private var rttFormatted: String {
    guard let rtt = rtt else {
      return "—"
    }
    let ms = rtt * 1000
    return String(format: "%.1f ms", ms)
  }

  public var body: some View {
    HStack(spacing: 12) {
      // Status indicator
      Image(systemName: success ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(success ? .green : .red)
        .font(.caption)

      // Transport method badge
      Image(systemName: method.icon)
        .foregroundColor(method.color)
        .font(.caption)
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 2) {
        // Timestamp and method name
        HStack(spacing: 6) {
          Text(timestamp, style: .time)
            .font(.caption)
            .fontWeight(.medium)

          Text(method.displayName)
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        // Size and RTT
        HStack(spacing: 8) {
          Label(sizeFormatted, systemImage: "doc")
            .font(.caption2)
            .foregroundColor(.secondary)

          if rtt != nil {
            Label(rttFormatted, systemImage: "clock")
              .font(.caption2)
              .foregroundColor(.secondary)
          }
        }
      }

      Spacer()
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 8)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Color.subtleBackgroundColor)
    )
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  struct MessageHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
      ScrollView {
        VStack(spacing: 8) {
          // Successful messages with RTT
          MessageHistoryRow(
            timestamp: Date(),
            method: .sendMessage,
            size: 256,
            rtt: 0.023,
            success: true
          )

          MessageHistoryRow(
            timestamp: Date().addingTimeInterval(-10),
            method: .sendMessageData,
            size: 1024,
            rtt: 0.018,
            success: true
          )

          // One-way message (no RTT)
          MessageHistoryRow(
            timestamp: Date().addingTimeInterval(-20),
            method: .updateApplicationContext,
            size: 512,
            rtt: nil,
            success: true
          )

          // Failed message
          MessageHistoryRow(
            timestamp: Date().addingTimeInterval(-30),
            method: .sendMessage,
            size: 128,
            rtt: nil,
            success: false
          )

          // Large payload
          MessageHistoryRow(
            timestamp: Date().addingTimeInterval(-40),
            method: .sendMessageData,
            size: 16384,
            rtt: 0.045,
            success: true
          )
        }
        .padding()
      }
      .previewLayout(.sizeThatFits)
    }
  }
#endif
