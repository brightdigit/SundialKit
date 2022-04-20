@testable import SundialKit
import XCTest

class WCSendMessageResultTests: XCTestCase {
  func testResult() {
    guard case .reply = WCSendMessageResult(.success(.init())) else {
      XCTFail()
      return
    }

    guard case .failure = WCSendMessageResult(
      .failure(SundialError.sessionNotSupported)
    ) else {
      XCTFail()
      return
    }
  }
}
