#if canImport(Network)
  import Network

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension NWPathMonitor: PathMonitor {
    public func onPathUpdate(_ handler: @escaping (NWPath) -> Void) {
      pathUpdateHandler = handler
    }
  }

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  public extension NetworkObserver {
    /// Default implementation of `NetworkObserver`
    /// which does not use execute a perodic ``NetworkPing``.
    convenience init() where MonitorType == NWPathMonitor, PingType == NeverPing {
      let monitor = NWPathMonitor()
      self.init(monitor: monitor)
    }

    /// Default implementation of `NetworkObserver`
    /// which does use execute a perodic ``NetworkPing``.
    convenience init(ping: PingType) where MonitorType == NWPathMonitor {
      let monitor = NWPathMonitor()
      self.init(monitor: monitor, ping: ping)
    }
  }

#endif
