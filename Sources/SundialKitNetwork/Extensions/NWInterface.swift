//
//  NWInterface.swift
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

public import SundialKitCore

#if canImport(Network)

  public import Network

  // swiftlint:disable:next file_types_order
  extension NWInterface.InterfaceType {
    // swiftlint:disable:next explicit_acl
    var value: Int {
      switch self {
      case .other:
        return PathStatus.Interface.other.rawValue

      case .wifi:
        return PathStatus.Interface.wifi.rawValue

      case .cellular:
        return PathStatus.Interface.cellular.rawValue

      case .wiredEthernet:
        return PathStatus.Interface.wiredEthernet.rawValue

      case .loopback:
        return PathStatus.Interface.loopback.rawValue

      @unknown default:
        return 0
      }
    }
  }

  extension NWInterface: Interfaceable {
    /// The integer value representing the interface type.
    public var typeValue: Int {
      type.value
    }
  }
#endif
