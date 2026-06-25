//
//  MessageHistoryRow_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  public struct MessageHistoryRow_Previews: PreviewProvider {
    public static var previews: some View {
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
            size: 1_024,
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
            size: 16_384,
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
