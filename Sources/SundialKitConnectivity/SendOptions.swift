//
// SendOptions.swift
// Copyright (c) 2025 BrightDigit.
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

  /// The raw integer value of the option set.
  public let rawValue: Int

  /// Creates a new send options value with the given raw value.
  /// - Parameter rawValue: The raw integer value.
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}
