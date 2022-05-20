public enum PathStatus: Equatable {
  public enum UnsatisfiedReason: Equatable {
    case cellularDenied
    case localNetworkDenied
    case notAvailable
    case wifiDenied
    case unknown
  }

  public struct Interface: OptionSet, Interfaceable {
    public var typeValue: Int {
      rawValue
    }

    public var rawValue: Int

    public init(rawValue: RawValue) {
      self.rawValue = rawValue
    }

    public typealias RawValue = Int

    public static let cellular: Self = .init(rawValue: 1)
    public static let wifi: Self = .init(rawValue: 2)
    public static let wiredEthernet: Self = .init(rawValue: 4)
    public static let other: Self = .init(rawValue: 8)
    public static let loopback: Self = .init(rawValue: 16)
  }

  case unsatisfied(UnsatisfiedReason)
  case satisfied(Interface)
  case requiresConnection
  case unknown
}
