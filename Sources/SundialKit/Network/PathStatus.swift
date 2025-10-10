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

/// Status of a particular network path
public enum PathStatus: Equatable {
  /// Unable to connnect
  case unsatisfied(UnsatisfiedReason?)
  /// Able to connect with interface
  case satisfied(Interface)
  /// The path is not currently available, but establishing a new connection may activate the path.
  case requiresConnection
  /// Unknown status
  case unknown

  public enum UnsatisfiedReason: Equatable {
    case cellularDenied
    case localNetworkDenied
    case notAvailable
    case wifiDenied
    case unknown
    case unsupported
  }

  /// Types of network interfaces, based on their link layer media types.
  public struct Interface: OptionSet, Interfaceable {
    public var typeValue: Int {
      rawValue
    }

    public var rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// Converts a group of `Interfaceable` objects into a `PathStatus.Interface`
    /// - Parameter interfaces: A list of `PathStatus.Interface` object.
    internal init(interfaces: [Interfaceable]) {
      let rawValue = Set(interfaces.map(\.typeValue)).reduce(0, +)
      self.init(rawValue: rawValue)
    }

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
  }
}
