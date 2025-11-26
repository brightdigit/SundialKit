//
//  Date+Milliseconds.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation

public extension Date {
  /// Milliseconds since Unix epoch
  var timeIntervalSince1970Milliseconds: Int64 {
    Int64(timeIntervalSince1970 * 1_000)
  }

  /// Convenience alias for timeIntervalSince1970Milliseconds
  var millisecondsSince1970: Int64 {
    timeIntervalSince1970Milliseconds
  }

  /// Create a Date from milliseconds since Unix epoch
  init(millisecondsSince1970: Int64) {
    self.init(timeIntervalSince1970: Double(millisecondsSince1970) / 1_000.0)
  }

  /// Current time in milliseconds
  static var nowMilliseconds: Int64 {
    Date().timeIntervalSince1970Milliseconds
  }
}
