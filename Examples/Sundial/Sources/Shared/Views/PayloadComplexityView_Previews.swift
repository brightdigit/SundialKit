//
//  PayloadComplexityView_Previews.swift
//  Sundial
//
//  Created on 10/28/25.
//  Copyright (c) 2025 BrightDigit.
//

#if DEBUG
  import SwiftUI

  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  public struct PayloadComplexityView_Previews: PreviewProvider {
    public static var previews: some View {
      Group {
        PayloadComplexityView(complexityLevel: .constant(0.0))
          .previewDisplayName("Simple (0.0)")

        PayloadComplexityView(complexityLevel: .constant(0.5))
          .previewDisplayName("Medium (0.5)")

        PayloadComplexityView(complexityLevel: .constant(1.0))
          .previewDisplayName("Complex (1.0)")
      }
      .padding()
    }
  }
#endif
