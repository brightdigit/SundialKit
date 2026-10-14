#if canImport(Network)
  import Network

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension NWPath: NetworkPath {
    public var pathStatus: PathStatus {
      PathStatus(
        status,
        reason: unsatisfiedReason,
        interfaces: availableInterfaces.map {
          $0 as Interfaceable
        }
      )
    }
  }

#endif
