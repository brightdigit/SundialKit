//
//  ColorSelectorView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct ColorSelectorView_Previews: PreviewProvider {
    public static var previews: some View {
      Group {
        ScrollView {
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
