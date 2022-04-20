import Foundation
@testable import SundialKit

import XCTest

public class WCObjectInternalTests: XCTestCase {
  func testInit() throws {
    #if canImport(WatchConnectivity)
      let object = WCObject()
      XCTAssert(object.session is WatchConnectivitySession)
    #else
      throw XCTSkip("`WatchConnectivity` is not supported by this OS.")
    #endif
  }
}
