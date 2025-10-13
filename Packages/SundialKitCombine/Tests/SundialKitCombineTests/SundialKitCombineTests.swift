import XCTest

@testable import SundialKitCombine

internal final class SundialKitCombineTests: XCTestCase {
  internal func testVersionIsDefined() {
    XCTAssertFalse(SundialKitCombine.version.isEmpty)
  }
}
