import Foundation
import SundialKit

#if canImport(Network)
  import Network
#endif

import XCTest

public class NWInterfaceTests: XCTestCase {
  #if canImport(Network)
    func rawValue(
      of interface: PathStatus.Interface,
      interfaceType: NWInterface.InterfaceType
    ) {
      XCTAssertEqual(interface.rawValue, interfaceType.value)
    }
  #endif

  func testValue() throws {
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