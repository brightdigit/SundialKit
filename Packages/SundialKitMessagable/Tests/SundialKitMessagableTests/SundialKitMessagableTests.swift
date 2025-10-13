import XCTest

@testable import SundialKitMessagable

final class SundialKitMessagableTests: XCTestCase {
  func testVersionIsDefined() {
    XCTAssertFalse(SundialKitMessagable.version.isEmpty)
  }
}
