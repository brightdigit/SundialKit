@testable import SundialKit
import XCTest

internal class WCSendMessageResultTests: XCTestCase {
  internal func testResult() {
    guard case .reply = WCSendMessageResult(.success(.init())) else {
      XCTFail("Missing Reply")
      return
    }

    guard case .failure = WCSendMessageResult(
      .failure(SundialError.sessionNotSupported)
    ) else {
      XCTFail("Should be a failure")
      return
    }
  }
}
