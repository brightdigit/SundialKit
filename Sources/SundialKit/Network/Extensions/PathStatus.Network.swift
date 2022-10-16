// swiftlint:disable function_body_length cyclomatic_complexity
#if canImport(Network)
  import Network

  @available(macOS 10.14, *)
  public extension PathStatus {
    /// Creates a `PathStatus`.
    /// - Parameters:
    ///   - status: The `NWPath.Status`
    ///   - interfaces: The `Interfacable` objects.
    @available(macOS, obsoleted: 11.0)
    @available(iOS, obsoleted: 14.2)
    @available(watchOS, obsoleted: 7.0)
    internal init(
      _ status: NWPath.Status,
      interfaces: [Interfaceable]
    ) {
      self.init(status, reason: .unsupported, interfaces: interfaces)
    }

    /// Creates a `PathStatus`.
    /// - Parameters:
    ///   - status: The `NWPath.Status`
    ///   - reason: The `NWPath.UnsatisfiedReason`
    ///   - interfaces: The `Interfacable` objects.
    @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
    internal init(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [Interfaceable]
    ) {
      self.init(status, reason: UnsatisfiedReason(reason), interfaces: interfaces)
    }

    private init(
      _ status: NWPath.Status,
      reason: UnsatisfiedReason,
      interfaces: [Interfaceable]
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
