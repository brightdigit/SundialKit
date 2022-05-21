// swiftlint:disable file_types_order
#if canImport(Network)

  import Network
  @available(macOS 10.14, *)
  public extension NWInterface.InterfaceType {
    var value: Int {
      switch self {
      case .other:
        return PathStatus.Interface.other.rawValue

      case .wifi:
        return PathStatus.Interface.wifi.rawValue

      case .cellular:
        return PathStatus.Interface.cellular.rawValue

      case .wiredEthernet:
        return PathStatus.Interface.wiredEthernet.rawValue

      case .loopback:
        return PathStatus.Interface.loopback.rawValue
      @unknown default:
        return 0
      }
    }
  }

  @available(macOS 10.14, *)
  extension NWInterface: Interfaceable {
    public var typeValue: Int {
      type.value
    }
  }
#endif
