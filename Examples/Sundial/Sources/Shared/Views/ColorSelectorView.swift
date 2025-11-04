//
//  ColorSelectorView.swift
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

/// Color selector with platform-specific picker and preview.
///
/// Provides a color selection interface that adapts to the platform:
/// - watchOS: Uses a grid of predefined colors
/// - iOS/macOS: Uses the native ColorPicker
///
/// Includes a randomize button and color preview display.
///
/// Example usage:
/// ```swift
/// @State private var selectedColor: Color = .blue
///
/// ColorSelectorView(
///   selectedColor: $selectedColor,
///   onRandomize: { selectedColor = .random() }
/// )
/// ```
@available(iOS 16.0, watchOS 9.0, *)
struct ColorSelectorView: View {
  @Binding var selectedColor: Color
  let onRandomize: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Color")
          .font(.subheadline)
          .foregroundColor(.secondary)

        Spacer()

        Button(action: onRandomize) {
          #if os(watchOS)
            Image(systemName: "shuffle")
          #else
            Label("Random", systemImage: "shuffle")
              .font(.caption)
          #endif
        }
        .buttonStyle(.bordered)
      }

      #if os(watchOS)
        // watchOS: Use color grid since ColorPicker is not available
        ColorGridPickerView(selectedColor: $selectedColor)
      #else
        // iOS/macOS: Use standard ColorPicker
        ColorPicker("Color", selection: $selectedColor, supportsOpacity: true)
          .labelsHidden()
      #endif

      ColorPreview(
        color: selectedColor,
        size: 80
      )
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.grayBackgroundColor)
    )
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct ColorSelectorView_Previews: PreviewProvider {
    static var previews: some View {
      Group {
        ScrollView{
          ColorSelectorView(
            selectedColor: .constant(.blue),
            onRandomize: {}
          )
        }
        .previewDisplayName("Blue")

        ColorSelectorView(
          selectedColor: .constant(.red),
          onRandomize: {}
        )
        .previewDisplayName("Red")

        ColorSelectorView(
          selectedColor: .constant(.mint),
          onRandomize: {}
        )
        .previewDisplayName("Mint")
      }
      .padding()
    }
  }
#endif
