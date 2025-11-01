//
//  ColorWithMetadata.swift
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

/// Represents a color with associated metadata (timestamp and source).
///
/// Used to track sent and received colors in the Message Lab,
/// providing context about when and where the color originated.
public struct ColorWithMetadata: Equatable {
  /// The color value
  public let color: Color

  /// When the color was sent or received
  public let timestamp: Date

  /// Optional source identifier (e.g., "This Device", "Counterpart")
  public let source: String?

  /// Creates a new color with metadata.
  ///
  /// - Parameters:
  ///   - color: The color value
  ///   - timestamp: When the color was sent/received
  ///   - source: Optional source identifier
  public init(color: Color, timestamp: Date, source: String? = nil) {
    self.color = color
    self.timestamp = timestamp
    self.source = source
  }
}
