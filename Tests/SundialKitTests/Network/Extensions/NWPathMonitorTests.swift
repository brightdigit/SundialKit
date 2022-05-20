import Foundation
import SundialKit

#if canImport(Network)
  import Network
#endif
import XCTest

public class NWPathMonitorTests: XCTestCase {
  func testPathUpdate() throws {
    #if canImport(Network)
      let monitor = NWPathMonitor()
      XCTAssertNil(monitor.pathUpdateHandler)
      monitor.onPathUpdate { _ in
      }
      XCTAssertNotNil(monitor.pathUpdateHandler)
    #else
      throw XCTSkip("OS doesn't support Network.")
    #endif
  }
}
