import Foundation
import XCTest

@testable import SundialKit

#if canImport(Network)
  import Network
#endif

internal final class NWInterfaceTests: XCTestCase {
  #if canImport(Network)
    internal func rawValue(
      of interface: PathStatus.Interface,
      interfaceType: NWInterface.InterfaceType
    ) {
      XCTAssertEqual(interface.rawValue, interfaceType.value)
    }
  #endif

  internal func testValue() throws {
    #if canImport(Network)

      rawValue(of: .wifi, interfaceType: .wifi)
      rawValue(of: .wiredEthernet, interfaceType: .wiredEthernet)
      rawValue(of: .loopback, interfaceType: .loopback)
      rawValue(of: .cellular, interfaceType: .cellular)
      rawValue(of: .other, interfaceType: .other)
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }
}
