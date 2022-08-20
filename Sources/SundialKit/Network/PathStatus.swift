public enum PathStatus: Equatable {
  case unsatisfied(UnsatisfiedReason?)
  case satisfied(Interface)
  case requiresConnection
  case unknown

  public enum UnsatisfiedReason: Equatable {
    case cellularDenied
    case localNetworkDenied
    case notAvailable
    case wifiDenied
    case unknown
    case unsupported
  }

  public struct Interface: OptionSet, Interfaceable {
    public var typeValue: Int {
      rawValue
    }

    public var rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// Converts a group of `Interfaceable` objects into a `PathStatus.Interface`
    /// - Parameter interfaces: A list of `PathStatus.Interface` object.
    public init(interfaces: [Interfaceable]) {
      let rawValue = Set(interfaces.map(\.typeValue)).reduce(0, +)
      self.init(rawValue: rawValue)
    }

    public static let cellular: Self = .init(rawValue: 1)
    public static let wifi: Self = .init(rawValue: 2)
    public static let wiredEthernet: Self = .init(rawValue: 4)
    public static let other: Self = .init(rawValue: 8)
    public static let loopback: Self = .init(rawValue: 16)
  }
}
