import Foundation
import XCTest

@testable import SundialKit
@testable import SundialKitConnectivity

internal final class ConnectivityObserverInternalTests: XCTestCase {
  internal func testInit() throws {
    #if canImport(WatchConnectivity)
      let object = ConnectivityObserver()
      XCTAssert(object.session is WatchConnectivitySession)
    #else
      throw XCTSkip("`WatchConnectivity` is not supported by this OS.")
    #endif
  }
}
