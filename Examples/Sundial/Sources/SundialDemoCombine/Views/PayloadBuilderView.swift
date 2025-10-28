//
//  PayloadBuilderView.swift
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

import SundialDemoShared
import SwiftUI

/// Payload Builder section for selecting colors and complexity levels
@available(iOS 16.0, watchOS 9.0, *)
struct PayloadBuilderView: View {
  @Binding var selectedColor: Color
  @Binding var complexityLevel: Double
  let onRandomize: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Payload Builder")
        .font(.headline)

      ColorSelectorView(
        selectedColor: $selectedColor,
        onRandomize: onRandomize
      )

      PayloadComplexityView(
        complexityLevel: $complexityLevel
      )
    }
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct PayloadBuilderView_Previews: PreviewProvider {
    static var previews: some View {
      ScrollView{
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
