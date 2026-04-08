//
//  SundialLogger.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
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

#if canImport(os)
  package import os.log
#endif

// MARK: - Unified Logging Infrastructure

/// Unified logging infrastructure for SundialKit
///
/// Provides subsystem-based structured logging using OSLog/Logger framework
/// on Apple platforms, and print-based logging on other platforms.
/// Each SundialKit module has its own subsystem for organized log filtering.
package enum SundialLogger {
  #if !canImport(os)
    /// Fallback logger that prints to stdout
    package struct FallbackLogger {
      private let subsystem: String
      private let category: String

      fileprivate init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
      }

      package func error(_ message: String) {
        print("[\(subsystem):\(category)] ERROR: \(message)")
      }

      package func info(_ message: String) {
        print("[\(subsystem):\(category)] INFO: \(message)")
      }

      package func debug(_ message: String) {
        print("[\(subsystem):\(category)] DEBUG: \(message)")
      }
    }
  #endif

  // MARK: - Type Properties

  #if canImport(os)
    /// Core protocols and types
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let core = Logger(
      subsystem: "com.brightdigit.SundialKit.Core",
      category: "core"
    )

    /// Network monitoring (PathMonitor, NetworkPing)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let network = Logger(
      subsystem: "com.brightdigit.SundialKit.Network",
      category: "network"
    )

    /// WatchConnectivity abstractions
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let connectivity = Logger(
      subsystem: "com.brightdigit.SundialKit.Connectivity",
      category: "connectivity"
    )

    /// Stream-based observers (actor-based AsyncStream APIs)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let stream = Logger(
      subsystem: "com.brightdigit.SundialKit.Stream",
      category: "stream"
    )

    /// Combine-based observers (@MainActor with publishers)
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let combine = Logger(
      subsystem: "com.brightdigit.SundialKit.Combine",
      category: "combine"
    )

    /// Binary message encoding/decoding
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let binary = Logger(
      subsystem: "com.brightdigit.SundialKit.Binary",
      category: "binary"
    )

    /// Messagable protocol and message decoding
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let messagable = Logger(
      subsystem: "com.brightdigit.SundialKit.Messagable",
      category: "messagable"
    )

    /// Test infrastructure
    @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
    package static let test = Logger(
      subsystem: "com.brightdigit.SundialKit.Tests",
      category: "tests"
    )
  #else
    // MARK: - Fallback for non-Apple platforms (Linux, Windows)

    /// Core protocols and types
    package static let core = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Core",
      category: "core"
    )

    /// Network monitoring (PathMonitor, NetworkPing)
    package static let network = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Network",
      category: "network"
    )

    /// WatchConnectivity abstractions
    package static let connectivity = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Connectivity",
      category: "connectivity"
    )

    /// Stream-based observers (actor-based AsyncStream APIs)
    package static let stream = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Stream",
      category: "stream"
    )

    /// Combine-based observers (@MainActor with publishers)
    package static let combine = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Combine",
      category: "combine"
    )

    /// Binary message encoding/decoding
    package static let binary = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Binary",
      category: "binary"
    )

    /// Messagable protocol and message decoding
    package static let messagable = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Messagable",
      category: "messagable"
    )

    /// Test infrastructure
    package static let test = FallbackLogger(
      subsystem: "com.brightdigit.SundialKit.Tests",
      category: "tests"
    )
  #endif
}
