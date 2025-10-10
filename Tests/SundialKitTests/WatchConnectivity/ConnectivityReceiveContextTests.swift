import SundialKit
import XCTest

internal final class ConnectivityReceiveContextTests: XCTestCase {
  internal func testReplyHandler() {
    XCTAssertNil(ConnectivityReceiveContext.applicationContext.replyHandler)
    XCTAssertNotNil(
      ConnectivityReceiveContext.replyWith { _ in
      }.replyHandler)
  }

  internal func testIsApplicationContext() {
    XCTAssertTrue(ConnectivityReceiveContext.applicationContext.isApplicationContext)
    XCTAssertFalse(
      ConnectivityReceiveContext.replyWith { _ in
      }.isApplicationContext)
  }
}
