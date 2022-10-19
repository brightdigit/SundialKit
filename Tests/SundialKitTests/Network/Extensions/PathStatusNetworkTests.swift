import Foundation
@testable import SundialKit

#if canImport(Network)
  import Network
#endif

import XCTest

public final class PathStatusNetworkTests: XCTestCase {
  #if canImport(Network)

    @available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *)
    public func assertStatus(
      _ status: NWPath.Status,
      reason: NWPath.UnsatisfiedReason,
      interfaces: [PathStatus.Interface],
      equalsPathStatus expected: PathStatus
    ) {
      let actual: PathStatus = .init(status, reason: reason, interfaces: interfaces)
      XCTAssertEqual(actual, expected)
    }
  #endif
  // swiftlint:disable:next function_body_length
  public func testInit() throws {
    if #available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *) {
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
        return
      #endif
    }
    throw XCTSkip("Network framework unavailable.")
  }
}
