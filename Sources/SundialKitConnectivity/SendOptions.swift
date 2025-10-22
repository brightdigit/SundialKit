//
//  SendOptions.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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

/// Options for controlling message sending behavior.
public struct SendOptions: OptionSet, Sendable {
  /// Force dictionary transport even for BinaryMessagable types.
  ///
  /// By default, `BinaryMessagable` types use binary transport (`sendMessageData`).
  /// This option forces dictionary transport (`sendMessage`) instead, useful for:
  /// - Testing dictionary fallback behavior
  /// - Debugging serialization issues
  /// - Working with systems that don't support binary transport
  public static let forceDictionary = SendOptions(rawValue: 1 << 0)

  public let rawValue: Int

  /// Creates a new send options value with the given raw value.
  /// - Parameter rawValue: The raw integer value.
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}
