//
//  PathStatusNetworkTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork

#if canImport(Network)
  import Network
#endif

@Suite("PathStatus Network Tests")
internal struct PathStatusNetworkTests {
  #if canImport(Network)

    @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
    internal func assertStatus(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [PathStatus.Interface],
      equalsPathStatus expected: PathStatus
    ) {
      let actual: PathStatus = .init(status, reason: reason, interfaces: interfaces)
      #expect(actual == expected)
    }
  #endif

  #if canImport(Network)
    @Test(
      "PathStatus initialized from NWPath properties",
      arguments: [
        (
          NWPath.Status.satisfied, NWPath.UnsatisfiedReason.cellularDenied,
          [PathStatus.Interface.loopback, .cellular], PathStatus.satisfied([.loopback, .cellular])
        ),
        (
          NWPath.Status.requiresConnection, NWPath.UnsatisfiedReason.cellularDenied,
          [PathStatus.Interface.loopback, .cellular], PathStatus.requiresConnection
        ),
        (
          NWPath.Status.unsatisfied, NWPath.UnsatisfiedReason.cellularDenied,
          [PathStatus.Interface.loopback, .cellular], PathStatus.unsatisfied(.cellularDenied)
        ),
        (
          NWPath.Status.unsatisfied, NWPath.UnsatisfiedReason.notAvailable,
          [PathStatus.Interface.loopback, .cellular], PathStatus.unsatisfied(.notAvailable)
        ),
        (
          NWPath.Status.unsatisfied, NWPath.UnsatisfiedReason.localNetworkDenied,
          [PathStatus.Interface.loopback, .cellular], PathStatus.unsatisfied(.localNetworkDenied)
        ),
        (
          NWPath.Status.unsatisfied, NWPath.UnsatisfiedReason.wifiDenied,
          [PathStatus.Interface.loopback, .cellular], PathStatus.unsatisfied(.wifiDenied)
        ),
      ])
    @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
    internal func pathStatusInit(
      status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [PathStatus.Interface],
      expected: PathStatus
    ) throws {
      #if canImport(Network)
        assertStatus(status, reason: reason, interfaces: interfaces, equalsPathStatus: expected)
      #endif
    }
  #endif
}
