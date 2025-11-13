//
//  DemoLogger.swift
//  SundialDemo
//
//  Created on 2025-11-13.
//

import Foundation
import os.log

/// Logging infrastructure for SundialKit demo applications
@available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
internal enum DemoLogger {
  /// Demo application logger
  internal static let shared = Logger(
    subsystem: "com.brightdigit.SundialDemo",
    category: "demo"
  )
}
