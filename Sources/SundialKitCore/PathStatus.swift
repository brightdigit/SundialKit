//
//  PathStatus.swift
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

/// Status of a particular network path.
///
/// This enum represents the various states a network path can be in,
/// providing information about connectivity and the interfaces available.
public enum PathStatus: Equatable, Sendable {
  /// Unable to connect.
  ///
  /// - Parameter reason: An optional reason explaining why the path is unsatisfied.
  case unsatisfied(UnsatisfiedReason?)

  /// Able to connect with the specified interface.
  ///
  /// - Parameter interface: The network interface that satisfies the path.
  case satisfied(Interface)

  /// The path is not currently available, but establishing a new connection may activate the path.
  case requiresConnection

  /// Unknown status.
  case unknown

  /// Reasons why a network path may be unsatisfied.
  public enum UnsatisfiedReason: Equatable, Sendable {
    /// Cellular network access has been denied.
    case cellularDenied

    /// Local network access has been denied.
    case localNetworkDenied

    /// The network is not available.
    case notAvailable

    /// Wi-Fi network access has been denied.
    case wifiDenied

    /// The reason is unknown.
    case unknown

    /// The platform does not support this unsatisfied reason.
    case unsupported
  }

  /// Types of network interfaces, based on their link layer media types.
  ///
  /// This option set represents the various network interface types that can be used
  /// for communication. Multiple interface types can be combined.
  public struct Interface: OptionSet, Interfaceable, Sendable {
    /// The network interface type used for communication over cellular networks.
    public static let cellular: Self = .init(rawValue: 1)

    /// The network interface type used for communication over Wi-Fi networks.
    public static let wifi: Self = .init(rawValue: 2)

    /// The network interface type used for communication over wired Ethernet networks.
    public static let wiredEthernet: Self = .init(rawValue: 4)

    /// The network interface type used for communication
    /// over virtual networks or networks of unknown types.
    public static let other: Self = .init(rawValue: 8)

    /// The network interface type used for communication over local loopback networks.
    public static let loopback: Self = .init(rawValue: 16)

    /// Integer value which matches the interface type.
    public var typeValue: Int {
      rawValue
    }

    /// The raw value of the interface type.
    public var rawValue: Int

    /// Creates a new interface with the specified raw value.
    ///
    /// - Parameter rawValue: The raw integer value for the interface type.
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// Converts a group of `Interfaceable` objects into a `PathStatus.Interface`.
    ///
    /// This initializer is used to aggregate multiple network interfaces
    /// into a single Interface option set.
    ///
    /// - Parameter interfaces: A list of objects conforming to `Interfaceable`.
    public init(interfaces: [any Interfaceable]) {
      let rawValue = Set(interfaces.map(\.typeValue)).reduce(0, +)
      self.init(rawValue: rawValue)
    }
  }
}
