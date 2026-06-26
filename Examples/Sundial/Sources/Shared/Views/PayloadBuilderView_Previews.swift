//
//  PayloadBuilderView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct PayloadBuilderView_Previews: PreviewProvider {
    public static var previews: some View {
      ScrollView {
        PayloadBuilderView(
          selectedColor: .constant(.blue),
          complexityLevel: .constant(0.5),
          onRandomize: {}
        )
      }
      .padding()
    }
  }
#endif
