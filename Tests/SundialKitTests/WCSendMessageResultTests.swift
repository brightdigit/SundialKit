@testable import SundialKit
import XCTest

internal class WCSendMessageResultTests: XCTestCase {
  internal func testResult() {
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
