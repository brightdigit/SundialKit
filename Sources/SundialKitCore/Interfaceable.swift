//
//  Interfaceable.swift
//  SundialKit
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
