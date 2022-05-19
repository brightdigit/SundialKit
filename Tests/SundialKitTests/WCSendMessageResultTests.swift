@testable import SundialKit
import XCTest

internal class WCSendMessageResultTests: XCTestCase {
  internal func testResult() {
    guard case .reply = ConnectivitySendContext(.success(.init())) else {
      XCTFail("Missing Reply")
      return
    }

    guard case .failure = ConnectivitySendContext(
      .failure(SundialError.sessionNotSupported)
    ) else {
      XCTFail("Should be a failure")
      return
    }
  }
}
