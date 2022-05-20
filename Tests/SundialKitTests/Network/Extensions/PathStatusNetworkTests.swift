import Foundation
import SundialKit

#if canImport(Network)
  import Network
#endif

import XCTest

public class PathStatusNetworkTests: XCTestCase {
  #if canImport(Network)
    public func assertStatus(_ status: NWPath.Status,
                             reason: NWPath.UnsatisfiedReason,
                             interfaces: [PathStatus.Interface],
                             equalsPathStatus expected: PathStatus) {
      let actual: PathStatus = .init(status, reason: reason, interfaces: interfaces)
      XCTAssertEqual(actual, expected)
    }
  #endif
  public func testInit() throws {
    #if canImport(Network)
      assertStatus(
        .satisfied, reason: .cellularDenied, interfaces: [.loopback, .cellular],
        equalsPathStatus: .satisfied([.loopback, .cellular])
      )
      assertStatus(
        .requiresConnection, reason: .cellularDenied, interfaces: [.loopback, .cellular],
        equalsPathStatus: .requiresConnection
      )
      assertStatus(
        .unsatisfied, reason: .cellularDenied, interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.cellularDenied)
      )
      assertStatus(
        .unsatisfied, reason: .notAvailable, interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.notAvailable)
      )
      assertStatus(
        .unsatisfied, reason: .localNetworkDenied, interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.localNetworkDenied)
      )
      assertStatus(
        .unsatisfied, reason: .wifiDenied, interfaces: [.loopback, .cellular],
        equalsPathStatus: .unsatisfied(.wifiDenied)
      )
    #else
      throw XCTSkip("Network framework unavailable.")
    #endif
  }
}
