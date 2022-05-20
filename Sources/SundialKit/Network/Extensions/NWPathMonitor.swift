#if canImport(Network)
  import Network

  @available(iOS 14.2, *)
  @available(watchOS 7.1, *)
  @available(macOS 11.0, *)
  extension NWPathMonitor: PathMonitor {
    public func onPathUpdate(_ handler: @escaping (NWPath) -> Void) {
      pathUpdateHandler = handler
    }
  }

#endif
