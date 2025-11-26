//
// PathStatus.UnsatisfiedReason.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
public import SundialKitCore

#if canImport(Network)
  public import Network

  @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
  extension PathStatus.UnsatisfiedReason {
    /// Dictionary mapping for known NWPath.UnsatisfiedReason cases
    private static let mappings: [NWPath.UnsatisfiedReason: PathStatus.UnsatisfiedReason] = {
      var mappings: [NWPath.UnsatisfiedReason: PathStatus.UnsatisfiedReason] = [
        .notAvailable: .notAvailable,
        .cellularDenied: .cellularDenied,
        .wifiDenied: .wifiDenied,
        .localNetworkDenied: .localNetworkDenied,
      ]

      // Add vpnInactive mapping on newer platforms where it's available
      if #available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
        mappings[.vpnInactive] = .vpnInactive
      }

      return mappings
    }()

    /// Creates `UnsatisfiedReason` from a `Network` one.
    /// - Parameter reason: The `UnsatisfiedReason` from the `Network` API.
    public init(_ reason: NWPath.UnsatisfiedReason) {
      // Use mapping or fall back to unknown
      let value = Self.mappings[reason]
      assert(value != nil)
      self = value ?? .unknown
    }
  }
#endif
