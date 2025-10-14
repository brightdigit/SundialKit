import Foundation
import XCTest

@testable import SundialKitCore
import SundialKit

#if canImport(Network)
  import Network
#endif

internal final class NWPathMonitorTests: XCTestCase {
  internal func testPathUpdate() throws {
    #if canImport(Network)
      if #available(macOS 11.0, iOS 14.2, watchOS 7.1, tvOS 14.2, *) {
        let monitor = NWPathMonitor()
        XCTAssertNil(monitor.pathUpdateHandler)
        monitor.onPathUpdate { _ in
        }
        XCTAssertNotNil(monitor.pathUpdateHandler)
        return
      }
    #endif

    throw XCTSkip("OS doesn't support Network.")
  }
}
