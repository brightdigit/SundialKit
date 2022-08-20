#if canImport(Network)
  import Network

  @available(macOS 10.15, *)
  extension NWPath: NetworkPath {
    public var pathStatus: PathStatus {
      if #available(iOS 14.2, watchOS 7.1, macOS 11.0, *) {
        return PathStatus(
          status,
          reason: unsatisfiedReason,
          interfaces: availableInterfaces
        )
      } else {
        return PathStatus(
          status,
          interfaces: availableInterfaces
        )
      }
    }
  }

#endif
