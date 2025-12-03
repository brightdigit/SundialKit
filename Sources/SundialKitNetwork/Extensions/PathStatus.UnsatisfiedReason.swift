//
//  PathStatus.UnsatisfiedReason.swift
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

import Foundation
public import SundialKitCore

#if canImport(Network)
  public import Network

  @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
  extension PathStatus.UnsatisfiedReason {
    /// Dictionary mapping for known NWPath.UnsatisfiedReason cases
    private static let mappings: [NWPath.UnsatisfiedReason: PathStatus.UnsatisfiedReason] = {
      var mappings: [NWPath.UnsatisfiedReason: PathStatus.UnsatisfiedReason] = [
        .notAvailable: .notAvailable,
        .cellularDenied: .cellularDenied,
        .wifiDenied: .wifiDenied,
        .localNetworkDenied: .localNetworkDenied,
      ]

      // Add vpnInactive mapping on newer platforms where it's available
      if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
        mappings[.vpnInactive] = .vpnInactive
      }

      return mappings
    }()

    /// Creates `UnsatisfiedReason` from a `Network` one.
    /// - Parameter reason: The `UnsatisfiedReason` from the `Network` API.
    public init(_ reason: NWPath.UnsatisfiedReason) {
      // Use mapping or fall back to unknown
      let value = Self.mappings[reason]
      assert(value != nil)
      self = value ?? .unknown
    }
  }
#endif
