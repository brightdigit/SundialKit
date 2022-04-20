import SundialKit
import XCTest

public class WCMessageContextTests: XCTestCase {
  public func testReplyHandler() {
    XCTAssertNil(WCMessageContext.applicationContext.replyHandler)
    XCTAssertNotNil(WCMessageContext.replyWith { _ in
    }.replyHandler)
  }

  public func testIsApplicationContext() {
    XCTAssertTrue(WCMessageContext.applicationContext.isApplicationContext)
    XCTAssertFalse(WCMessageContext.replyWith { _ in
    }.isApplicationContext)
  }
}
