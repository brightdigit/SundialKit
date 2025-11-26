//
// NWInterface.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

#if canImport(Network)

  public import Network

  // swiftlint:disable:next file_types_order
  extension NWInterface.InterfaceType {
    // swiftlint:disable:next explicit_acl
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

  extension NWInterface: Interfaceable {
    /// The integer value representing the interface type.
    public var typeValue: Int {
      type.value
    }
  }
#endif
