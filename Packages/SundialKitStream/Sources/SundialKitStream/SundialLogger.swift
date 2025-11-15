//
//  SundialLogger.swift
//  SundialKitStream
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

import Foundation

#if canImport(os.log)
  import os.log
#endif

// swiftlint:disable file_types_order

#if canImport(os.log)
  /// Unified logging infrastructure for SundialKit
  ///
  /// Provides subsystem-based structured logging using OSLog/Logger framework.
  /// Each SundialKit module has its own subsystem for organized log filtering.
  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  internal enum SundialLogger {
    /// Core protocols and types
    internal static let core = Logger(
      subsystem: "com.brightdigit.SundialKit.Core",
      category: "core"
    )

    /// Network monitoring (PathMonitor, NetworkPing)
    internal static let network = Logger(
      subsystem: "com.brightdigit.SundialKit.Network",
      category: "network"
    )

    /// WatchConnectivity abstractions
    internal static let connectivity = Logger(
      subsystem: "com.brightdigit.SundialKit.Connectivity",
      category: "connectivity"
    )

    /// Stream-based observers (actor-based AsyncStream APIs)
    internal static let stream = Logger(
      subsystem: "com.brightdigit.SundialKit.Stream",
      category: "stream"
    )

    /// Combine-based observers (@MainActor with publishers)
    internal static let combine = Logger(
      subsystem: "com.brightdigit.SundialKit.Combine",
      category: "combine"
    )

    /// Binary message encoding/decoding
    internal static let binary = Logger(
      subsystem: "com.brightdigit.SundialKit.Binary",
      category: "binary"
    )

    /// Messagable protocol and message decoding
    internal static let messagable = Logger(
      subsystem: "com.brightdigit.SundialKit.Messagable",
      category: "messagable"
    )

    /// Test infrastructure
    internal static let test = Logger(
      subsystem: "com.brightdigit.SundialKit.Tests",
      category: "tests"
    )

    /// Create a custom logger for specific categories
    /// - Parameters:
    ///   - subsystem: Reverse DNS notation subsystem identifier
    ///   - category: Category within the subsystem
    /// - Returns: Configured Logger instance
    internal static func custom(subsystem: String, category: String) -> Logger {
      Logger(subsystem: subsystem, category: category)
    }
  }
#else
  // MARK: - Fallback for non-Apple platforms (Linux, Windows)

  /// Print-based logging fallback for platforms without OSLog
  ///
  /// Provides the same API as SundialLogger but uses print() for output
  internal enum SundialLogger {
    /// Fallback logger that prints to stdout
    internal struct FallbackLogger {
      internal let subsystem: String
      internal let category: String

      internal func error(_ message: String) {
        print("[\(subsystem):\(category)] ERROR: \(message)")
      }

      internal func info(_ message: String) {
        print("[\(subsystem):\(category)] INFO: \(message)")
      }

      internal func debug(_ message: String) {
        print("[\(subsystem):\(category)] DEBUG: \(message)")
      }
    }

    /// Core protocols and types
    internal static let core = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Core",
      category: "core"
    )

    /// Network monitoring (PathMonitor, NetworkPing)
    internal static let network = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Network",
      category: "network"
    )

    /// WatchConnectivity abstractions
    internal static let connectivity = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Connectivity",
      category: "connectivity"
    )

    /// Stream-based observers (actor-based AsyncStream APIs)
    internal static let stream = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Stream",
      category: "stream"
    )

    /// Combine-based observers (@MainActor with publishers)
    internal static let combine = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Combine",
      category: "combine"
    )

    /// Binary message encoding/decoding
    internal static let binary = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Binary",
      category: "binary"
    )

    /// Messagable protocol and message decoding
    internal static let messagable = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Messagable",
      category: "messagable"
    )

    /// Test infrastructure
    internal static let test = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Tests",
      category: "tests"
    )

    /// Create a custom logger for specific categories
    /// - Parameters:
    ///   - subsystem: Reverse DNS notation subsystem identifier
    ///   - category: Category within the subsystem
    /// - Returns: Configured FallbackLogger instance
    internal static func custom(subsystem: String, category: String) -> FallbackLogger {
      FallbackLogger(subsystem: subsystem, category: category)
    }
  }
#endif
// swiftlint:enable file_types_order
