//
//  ColorPreview_Previews.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 14.8, watchOS 7.4, *)
  public struct ColorPreview_Previews: PreviewProvider {
    public static var previews: some View {
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
