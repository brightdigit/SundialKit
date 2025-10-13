import XCTest

@testable import SundialKitMessagable

internal final class SundialKitMessagableTests: XCTestCase {
  internal func testVersionIsDefined() {
    XCTAssertFalse(SundialKitMessagable.version.isEmpty)
  }
}
