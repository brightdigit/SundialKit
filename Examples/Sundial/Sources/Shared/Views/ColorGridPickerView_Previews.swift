//
//  ColorGridPickerView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(watchOS 9.0, *)
  public struct ColorGridPickerView_Previews: PreviewProvider {
    public static var previews: some View {
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
