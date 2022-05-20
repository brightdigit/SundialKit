#if canImport(Network)
  import Network

  @available(watchOS 7.1, *)
  @available(iOS 14.2, *)
  @available(macOS 11.0, *)
  public extension PathStatus {
    init(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
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