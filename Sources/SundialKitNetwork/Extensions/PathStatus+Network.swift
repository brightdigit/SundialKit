//
// PathStatus+Network.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(Network)
  import Network
  import SundialKitCore

  extension PathStatus {
    /// Creates a `PathStatus`.
    /// - Parameters:
    ///   - status: The `NWPath.Status`
    ///   - interfaces: The `Interfacable` objects.
    internal init(
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
