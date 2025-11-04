//
//  ErrorSectionView.swift
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

/// Error display section for showing error messages
@available(iOS 16.0, watchOS 9.0, *)
public struct ErrorSectionView: View {
  public let error: String

  public init(error: String) {
    self.error = error
  }

  public var body: some View {
    HStack(spacing: 12) {
      Image(systemName: "exclamationmark.triangle.fill")
        .foregroundColor(.red)

      Text(error)
        .font(.caption)
        .foregroundColor(.red)

      Spacer()
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.red.opacity(0.1))
    )
  }
}

#if DEBUG
  // MARK: - Previews

  @available(iOS 16.0, watchOS 9.0, *)
  struct ErrorSectionView_Previews: PreviewProvider {
    static var previews: some View {
      ErrorSectionView(error: "Failed to send message: Connection timeout")
        .padding()
    }
  }
#endif
