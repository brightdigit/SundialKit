//
//  PathStatus+Network.swift
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

#if canImport(Network)
  import Network
  public import SundialKitCore

  @available(macOS 10.14, *)
  extension PathStatus {
    /// Creates a `PathStatus`.
    /// - Parameters:
    ///   - status: The `NWPath.Status`
    ///   - interfaces: The `Interfacable` objects.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.2)
    @available(watchOS, obsoleted: 7.0)
    @available(tvOS, obsoleted: 14.2)
    // swiftlint:disable:next explicit_acl
    init(
      _ status: NWPath.Status,
      interfaces: [any Interfaceable]
    ) {
      self.init(status, reason: .unsupported, interfaces: interfaces)
    }

    /// Creates a `PathStatus`.
    /// - Parameters:
    ///   - status: The `NWPath.Status`
    ///   - reason: The `NWPath.UnsatisfiedReason`
    ///   - interfaces: The `Interfacable` objects.
    @available(iOS 14.2, watchOS 7.1, macOS 11.0, tvOS 14.2, *)
    // swiftlint:disable:next explicit_acl
    init(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [any Interfaceable]
    ) {
      self.init(status, reason: UnsatisfiedReason(reason), interfaces: interfaces)
    }

    // swiftlint:disable:next cyclomatic_complexity
    private init(
      _ status: NWPath.Status,
      reason: UnsatisfiedReason,
      interfaces: [any Interfaceable]
    ) {
      switch (status, reason) {
      case (.satisfied, _):
        self = .satisfied(PathStatus.Interface(interfaces: interfaces))

      case (.unsatisfied, .cellularDenied):
        self = .unsatisfied(.cellularDenied)

      case (.requiresConnection, _):
        self = .requiresConnection

      case (.unsatisfied, .notAvailable):
        self = .unsatisfied(.notAvailable)

      case (.unsatisfied, .wifiDenied):
        self = .unsatisfied(.wifiDenied)

      case (.unsatisfied, .localNetworkDenied):
        self = .unsatisfied(.localNetworkDenied)

      case (.unsatisfied, _):
        self = .unsatisfied(.unknown)

      case (_, _):
        self = .unknown
      }
    }
  }

#endif
