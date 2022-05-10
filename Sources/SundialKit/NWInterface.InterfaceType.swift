#if canImport(Network)

  import Network
  @available(macOS 10.14, *)
  public extension NWInterface.InterfaceType {
    var value: Int {
      switch self {
      case .other:
        return NWPathStatus.Interface.other.rawValue

      case .wifi:
        return NWPathStatus.Interface.wifi.rawValue

      case .cellular:
        return NWPathStatus.Interface.cellular.rawValue

      case .wiredEthernet:
        return NWPathStatus.Interface.wiredEthernet.rawValue

      case .loopback:
        return NWPathStatus.Interface.loopback.rawValue
      @unknown default:
        return 0
      }
    }
  }
#endif
