//
//  PayloadComplexityView.swift
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

/// Complexity slider for selecting message payload size.
///
/// Displays a slider control that allows users to choose between
/// simple (ColorMessage, 16 bytes) and complex (ComplexMessage, 256+ bytes)
/// payload types.
///
/// Example usage:
/// ```swift
/// @State private var complexityLevel: Double = 0.5
///
/// PayloadComplexityView(complexityLevel: $complexityLevel)
/// ```
@available(iOS 16.0, watchOS 9.0, *)
public struct PayloadComplexityView: View {
  @Binding internal var complexityLevel: Double

  private var complexityLabel: String {
    if complexityLevel < 0.5 {
      return "ColorMessage (16 bytes)"
    } else {
      return "ComplexMessage (256+ bytes)"
    }
  }

  public var body: some View {
    VStack(spacing: 8) {
      #if os(watchOS)
      HStack {
        Text("Complexity")
          .font(.subheadline)
          .foregroundColor(.secondary)

        Spacer()

        Text(complexityLevel, format: .number.precision(.fractionLength(2)))
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.blue)
      }
      #else
      HStack {
        Text("Payload Complexity")
          .font(.subheadline)
          .foregroundColor(.secondary)

        Spacer()

        Text(complexityLabel)
          .font(.caption)
          .fontWeight(.medium)
          .foregroundColor(.blue)
      }
      #endif

      Slider(value: $complexityLevel, in: 0...1)

      HStack {
        Text("Simple")
          .font(.caption2)
          .foregroundColor(.secondary)

        Spacer()

        Text("Complex")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.grayBackgroundColor)
    )
  }
}
