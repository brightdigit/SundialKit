//
//  PathStatusNetworkTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKit
@testable import SundialKitCore
@testable import SundialKitNetwork

#if canImport(Network)
  import Network
#endif

@Suite("PathStatus Network Tests")
struct PathStatusNetworkTests {
  #if canImport(Network)

    @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
    func assertStatus(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [PathStatus.Interface],
      equalsPathStatus expected: PathStatus
    ) {
      let actual: PathStatus = .init(status, reason: reason, interfaces: interfaces)
      #expect(actual == expected)
    }
  #endif

  @Test("PathStatus initialized from NWPath properties")
  @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
  func pathStatusInit() throws {
    #if canImport(Network)
      assertStatus(
        .satisfied,
        reason: .cellularDenied,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .satisfied([.loopback, .cellular])
      )
      assertStatus(
        .requiresConnection,
        reason: .cellularDenied,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .requiresConnection
      )
      assertStatus(
        .unsatisfied,
        reason: .cellularDenied,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.cellularDenied)
      )
      assertStatus(
        .unsatisfied,
        reason: .notAvailable,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.notAvailable)
      )
      assertStatus(
        .unsatisfied,
        reason: .localNetworkDenied,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.localNetworkDenied)
      )
      assertStatus(
        .unsatisfied,
        reason: .wifiDenied,
        interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.wifiDenied)
      )
    #endif
  }
}
