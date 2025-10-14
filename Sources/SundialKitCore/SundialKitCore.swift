//
//  SundialKitCore.swift
//  SundialKit
//
//  Created on 2025-01-13.
//

/// SundialKitCore provides foundational protocols and types for network monitoring
/// and connectivity management across Apple platforms.
///
/// This module defines the core abstractions that enable a plugin-based architecture,
/// allowing different reactive patterns (Combine, AsyncStream) and serialization
/// strategies to be layered on top of the base functionality.
public enum SundialKitCore {
  /// The current version of SundialKitCore
  public static let version = "2.0.0"
}
