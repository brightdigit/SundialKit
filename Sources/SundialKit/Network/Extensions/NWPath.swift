#if canImport(Network)
  import Network

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension NWPath: NetworkPath {
    public var pathStatus: PathStatus {
      if #available(iOS 14.2, watchOS 7.1, macOS 11.0, tvOS 14.2, *) {
        return PathStatus(
          status,
          reason: unsatisfiedReason,
          interfaces: availableInterfaces.map {
            $0 as Interfaceable
          }
        )
      } else {
        return PathStatus(
          status,
          interfaces: availableInterfaces.map {
            $0 as Interfaceable
          }
        )
      }
    }
  }

#endif
