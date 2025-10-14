//
//  SundialKit.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

// Re-export all modules for convenience
@_exported import SundialKitCore
@_exported import SundialKitNetwork
@_exported import SundialKitConnectivity

/// SundialKit is an umbrella module that re-exports all core functionality.
///
/// Import this module to get access to all SundialKit features:
/// - SundialKitCore: Protocol definitions and base types
/// - SundialKitNetwork: Network monitoring implementation
/// - SundialKitConnectivity: WatchConnectivity management
///
/// For more fine-grained control, you can import individual modules directly.
public enum SundialKit {
  /// The current version of SundialKit
  public static let version = "2.0.0"
}
