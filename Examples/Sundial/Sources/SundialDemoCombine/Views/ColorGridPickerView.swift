//
//  ColorGridPickerView.swift
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

/// A grid-based color picker designed for watchOS.
///
/// Displays a grid of predefined colors as interactive circles.
/// The selected color is indicated with a white border.
///
/// Example usage:
/// ```swift
/// @State private var selectedColor: Color = .blue
///
/// ColorGridPickerView(selectedColor: $selectedColor)
/// ```
@available(watchOS 9.0, *)
struct ColorGridPickerView: View {
  @Binding var selectedColor: Color

  private let colors: [Color] = [
    .red, .orange, .yellow, .green, .blue, .purple,
    .pink, .cyan, .mint, .indigo, .brown, .gray
  ]

  var body: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 8) {
      ForEach(colors.indices, id: \.self) { index in
        Circle()
          .fill(colors[index])
          .frame(width: 40, height: 40)
          .overlay(
            Circle()
              .strokeBorder(
                Color.white,
                lineWidth: selectedColor.isSimilar(to: colors[index]) ? 3 : 0
              )
          )
          .onTapGesture {
            selectedColor = colors[index]
          }
      }
    }
  }
}

// MARK: - Color Comparison Extension

private extension Color {
  func isSimilar(to other: Color) -> Bool {
    // Simple comparison for predefined colors
    self == other
  }
}

#if DEBUG
  // MARK: - Previews

  @available(watchOS 9.0, *)
  struct ColorGridPickerView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        ColorGridPickerView(selectedColor: .constant(.blue))
          .previewDisplayName("Blue Selected")

        ColorGridPickerView(selectedColor: .constant(.red))
          .previewDisplayName("Red Selected")

        ColorGridPickerView(selectedColor: .constant(.mint))
          .previewDisplayName("Mint Selected")
      }
      .padding()
    }
  }
#endif
