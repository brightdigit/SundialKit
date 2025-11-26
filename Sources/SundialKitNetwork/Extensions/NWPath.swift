//
// NWPath.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

#if canImport(Network)
  public import Network

  extension NWPath: NetworkPath {
    /// The current network path status with interface and reason information.
    public var pathStatus: PathStatus {
      if #available(iOS 14.2, watchOS 7.1, macOS 11.0, tvOS 14.2, *) {
        return PathStatus(
          status,
          reason: unsatisfiedReason,
          interfaces: availableInterfaces.map {
            $0 as any Interfaceable
          }
        )
      } else {
        return PathStatus(
          status,
          interfaces: availableInterfaces.map {
            $0 as any Interfaceable
          }
        )
      }
    }
  }

#endif
