//
//  PresetColorGrid.swift
//  Sundial
//
//  A small cross-platform color picker for the "Context Sync" demo.
//
//  Copyright (c) 2026 BrightDigit.
//

#if os(iOS) || os(watchOS)
  import SwiftUI

  /// A small cross-platform color picker (SwiftUI's `ColorPicker` is unavailable on
  /// watchOS), so the demo runs identically on iPhone and Apple Watch.
  @available(iOS 18.0, watchOS 11.0, *)
  internal struct PresetColorGrid: View {
    @Binding internal var selectedColor: Color

    private let colors: [Color] = [
      .red, .orange, .yellow, .green, .mint, .teal,
      .cyan, .blue, .indigo, .purple, .pink, .brown,
    ]

    internal var body: some View {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 8)], spacing: 8) {
        ForEach(colors.indices, id: \.self) { index in
          Button {
            selectedColor = colors[index]
          } label: {
            Circle()
              .fill(colors[index])
              .frame(width: 40, height: 40)
              .overlay(
                Circle().strokeBorder(.primary, lineWidth: 3)
                  .opacity(colors[index] == selectedColor ? 1 : 0)
              )
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.vertical, 4)
    }
  }
#endif
