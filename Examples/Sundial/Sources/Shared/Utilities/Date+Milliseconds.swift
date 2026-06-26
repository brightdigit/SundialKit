//
//  Date+Milliseconds.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation

extension Date {
  /// Current time in milliseconds
  public static var nowMilliseconds: Int64 {
    Date().timeIntervalSince1970Milliseconds
  }

  /// Milliseconds since Unix epoch
  public var timeIntervalSince1970Milliseconds: Int64 {
    Int64(timeIntervalSince1970 * 1_000)
  }

  /// Convenience alias for timeIntervalSince1970Milliseconds
  public var millisecondsSince1970: Int64 {
    timeIntervalSince1970Milliseconds
  }

  /// Create a Date from milliseconds since Unix epoch
  public init(millisecondsSince1970: Int64) {
    self.init(timeIntervalSince1970: Double(millisecondsSince1970) / 1_000.0)
  }
}
