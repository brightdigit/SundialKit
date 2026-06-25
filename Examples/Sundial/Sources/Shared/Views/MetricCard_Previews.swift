//
//  MetricCard_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  public struct MetricCard_Previews: PreviewProvider {
    public static var previews: some View {
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
