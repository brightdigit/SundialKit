import XCTest
@testable import SundialKitCombine

final class SundialKitCombineTests: XCTestCase {
  func testVersionIsDefined() {
    XCTAssertFalse(SundialKitCombine.version.isEmpty)
  }
}
