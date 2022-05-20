import Foundation
@testable import SundialKit

import XCTest

public class ConnectivityObserverInternalTests: XCTestCase {
  internal func testInit() throws {
    #if canImport(WatchConnectivity)
      let object = ConnectivityObserver()
      XCTAssert(object.session is WatchConnectivitySession)
    #else
      throw XCTSkip("`WatchConnectivity` is not supported by this OS.")
    #endif
  }
}
