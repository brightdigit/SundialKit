import SundialKit
import XCTest

public class ConnectivityReceiveContextTests: XCTestCase {
  public func testReplyHandler() {
    XCTAssertNil(ConnectivityReceiveContext.applicationContext.replyHandler)
    XCTAssertNotNil(ConnectivityReceiveContext.replyWith { _ in
    }.replyHandler)
  }

  public func testIsApplicationContext() {
    XCTAssertTrue(ConnectivityReceiveContext.applicationContext.isApplicationContext)
    XCTAssertFalse(ConnectivityReceiveContext.replyWith { _ in
    }.isApplicationContext)
  }
}
