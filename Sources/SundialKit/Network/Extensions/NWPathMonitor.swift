#if canImport(Network)
  import Network

  @available(macOS 10.15, *)
  extension NWPathMonitor: PathMonitor {
    public func onPathUpdate(_ handler: @escaping (NWPath) -> Void) {
      pathUpdateHandler = handler
    }
  }

#endif
