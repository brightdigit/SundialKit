#if canImport(Network)
  import Network

  @available(macOS 10.15, *)
  extension NWPathMonitor: PathMonitor {
    public func onPathUpdate(_ handler: @escaping (NWPath) -> Void) {
      pathUpdateHandler = handler
    }
  }


@available(macOS 10.15, *)
public extension NetworkObserver {
  convenience init() where MonitorType == NWPathMonitor, PingType == NeverPing {
    let monitor = NWPathMonitor()
    self.init(monitor: monitor)
  }
  
  convenience init(ping: PingType) where MonitorType == NWPathMonitor  {
    let monitor = NWPathMonitor()
    self.init(monitor: monitor, ping: ping)
  }
}

#endif
