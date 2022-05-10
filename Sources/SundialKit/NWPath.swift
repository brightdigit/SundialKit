#if canImport(Network)
  import Network
  @available(watchOS 7.1, *)
  @available(iOS 14.2, *)
  @available(macOS 11.0, *)
  extension NWPath: NWPathable {
    public var pathStatus: NWPathStatus {
      .init(status, reason: unsatisfiedReason, interfaces: availableInterfaces)
    }
  }
#endif
