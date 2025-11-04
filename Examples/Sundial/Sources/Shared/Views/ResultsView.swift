//
//  ResultsView.swift
//  Sundial
//
//  Created on 10/28/25.
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

/// Results section displaying sent and received colors with metadata
@available(iOS 16.0, watchOS 9.0, *)
public struct ResultsView: View {
  public let lastSentColor: ColorWithMetadata?
  public let lastReceivedColor: ColorWithMetadata?
  public let messagesSent: Int
  public let messagesReceived: Int

  public init(
    lastSentColor: ColorWithMetadata?,
    lastReceivedColor: ColorWithMetadata?,
    messagesSent: Int,
    messagesReceived: Int
  ) {
    self.lastSentColor = lastSentColor
    self.lastReceivedColor = lastReceivedColor
    self.messagesSent = messagesSent
    self.messagesReceived = messagesReceived
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Results")
        .font(.headline)

      HStack(spacing: 16) {
        // Sent
        VStack(spacing: 12) {
          Text("Sent")
            .font(.caption)
            .foregroundColor(.secondary)

          if let sent = lastSentColor {
            ColorPreview(
              color: sent.color,
              timestamp: sent.timestamp,
              source: "This Device"
            )
          } else {
            ColorPreview(
              color: .gray.opacity(0.3),
              size: 60
            )
            .overlay(
              Text("—")
                .font(.title)
                .foregroundColor(.secondary)
            )
          }

          Text("\(messagesSent)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }

        Divider()

        // Received
        VStack(spacing: 12) {
          Text("Received")
            .font(.caption)
            .foregroundColor(.secondary)

          if let received = lastReceivedColor {
            ColorPreview(
              color: received.color,
              timestamp: received.timestamp,
              source: "Counterpart"
            )
          } else {
            ColorPreview(
              color: .gray.opacity(0.3),
              size: 60
            )
            .overlay(
              Text("—")
                .font(.title)
                .foregroundColor(.secondary)
            )
          }

          Text("\(messagesReceived)")
            .font(.caption2)
            .foregroundColor(.secondary)
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.grayBackgroundColor)
      )
    }
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
      ResultsView(
        lastSentColor: ColorWithMetadata(
          color: .blue,
          timestamp: Date(),
          source: "This Device"
        ),
        lastReceivedColor: ColorWithMetadata(
          color: .red,
          timestamp: Date(),
          source: "Counterpart"
        ),
        messagesSent: 5,
        messagesReceived: 3
      )
      .padding()
    }
  }
#endif
