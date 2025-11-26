//
// SundialLogger.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation

#if canImport(os)
  package import os.log
#endif

#if canImport(os)
  /// Unified logging infrastructure for SundialKit
  ///
  /// Provides subsystem-based structured logging using OSLog/Logger framework.
  /// Each SundialKit module has its own subsystem for organized log filtering.
  @available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *)
  package enum SundialLogger {
    // swiftlint:disable:previous file_types_order

    /// Core protocols and types
    package static let core = Logger(subsystem: "com.brightdigit.SundialKit.Core", category: "core")

    /// Network monitoring (PathMonitor, NetworkPing)
    package static let network = Logger(
      subsystem: "com.brightdigit.SundialKit.Network",
      category: "network"
    )

    /// WatchConnectivity abstractions
    package static let connectivity = Logger(
      subsystem: "com.brightdigit.SundialKit.Connectivity",
      category: "connectivity"
    )

    /// Stream-based observers (actor-based AsyncStream APIs)
    package static let stream = Logger(
      subsystem: "com.brightdigit.SundialKit.Stream",
      category: "stream"
    )

    /// Combine-based observers (@MainActor with publishers)
    package static let combine = Logger(
      subsystem: "com.brightdigit.SundialKit.Combine",
      category: "combine"
    )

    /// Binary message encoding/decoding
    package static let binary = Logger(
      subsystem: "com.brightdigit.SundialKit.Binary",
      category: "binary"
    )

    /// Messagable protocol and message decoding
    package static let messagable = Logger(
      subsystem: "com.brightdigit.SundialKit.Messagable",
      category: "messagable"
    )

    /// Test infrastructure
    package static let test = Logger(
      subsystem: "com.brightdigit.SundialKit.Tests",
      category: "tests"
    )

    /// Create a custom logger for specific categories
    /// - Parameters:
    ///   - subsystem: Reverse DNS notation subsystem identifier
    ///   - category: Category within the subsystem
    /// - Returns: Configured Logger instance
    package static func custom(subsystem: String, category: String) -> Logger {
      Logger(subsystem: subsystem, category: category)
    }
  }
#else
  // MARK: - Fallback for non-Apple platforms (Linux, Windows)

  /// Print-based logging fallback for platforms without OSLog
  ///
  /// Provides the same API as SundialLogger but uses print() for output
  package enum SundialLogger {
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

    /// Create a custom logger for specific categories
    /// - Parameters:
    ///   - subsystem: Reverse DNS notation subsystem identifier
    ///   - category: Category within the subsystem
    /// - Returns: Configured FallbackLogger instance
    package static func custom(subsystem: String, category: String) -> FallbackLogger {
      FallbackLogger(subsystem: subsystem, category: category)
    }
  }
#endif
