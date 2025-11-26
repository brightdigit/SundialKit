//
// Interfaceable.swift
// Copyright (c) 2025 BrightDigit.
//

/// Defines an object which can be used as a path interface.
///
/// This protocol is primarily used internally for converting platform-specific
/// network interface types (like `NWInterface.InterfaceType`) to ``PathStatus/Interface`` values.
///
/// ## Overview
///
/// Platform implementations conform to this protocol to enable automatic conversion
/// from Apple's Network framework types to SundialKit's unified interface representation.
///
/// ## Example
///
/// Conforming a custom type:
///
/// ```swift
/// extension NWInterface.InterfaceType: Interfaceable {
///   public var typeValue: Int {
///     switch self {
///     case .cellular: return 1
///     case .wifi: return 2
///     case .wiredEthernet: return 4
///     case .loopback: return 16
///     case .other: return 8
///     @unknown default: return 8
///     }
///   }
/// }
/// ```
///
/// > Note: This protocol is typically not used directly by consumer code. It's implemented
/// > by SundialKitNetwork to bridge Apple's Network framework types.
public protocol Interfaceable {
  /// Integer value which matches the ``PathStatus/Interface`` values.
  ///
  /// The value should match one of the raw values defined in ``PathStatus/Interface``:
  /// - `1` for cellular
  /// - `2` for wifi
  /// - `4` for wiredEthernet
  /// - `8` for other
  /// - `16` for loopback
  var typeValue: Int { get }
}
