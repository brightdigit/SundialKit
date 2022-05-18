#if canImport(Network)
  import Network
  @available(watchOS 7.1, *)
  @available(iOS 14.2, *)
  @available(macOS 11.0, *)
  extension NWPath: NetworkPath {
    public var pathStatus: PathStatus {
      .init(status, reason: unsatisfiedReason, interfaces: availableInterfaces)
    }
  }
#endif
