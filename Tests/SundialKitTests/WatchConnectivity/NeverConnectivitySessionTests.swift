import XCTest

@testable import SundialKit

internal final class NeverConnectivitySessionTests: XCTestCase {
  private let session = NeverConnectivitySession()

  internal func testDelegateGet() {
    XCTAssertNil(session.delegate)
  }

  internal func testIsReachable() {
    XCTAssertFalse(session.isReachable)
  }

  internal func testIsPaired() {
    XCTAssertFalse(session.isPaired)
  }

  internal func testIsPairedAppInstalled() {
    XCTAssertFalse(session.isPairedAppInstalled)
  }

  internal func testActivationState() {
    XCTAssertEqual(session.activationState, .notActivated)
  }

  internal func testActivate() {
    XCTAssertThrowsError(try session.activate()) { error in
      XCTAssertEqual(error as? SundialError, SundialError.sessionNotSupported)
    }
  }

  internal func testUpdateApplicationContext() {
    XCTAssertThrowsError(try session.updateApplicationContext(.init())) { error in
      XCTAssertEqual(error as? SundialError, SundialError.sessionNotSupported)
    }
  }

  internal func testSendMessage() {
    let messageSentDone = expectation(description: "Message Sent Done")
    session.sendMessage(.init()) { result in
      guard case .failure(let error as SundialError) = result else {
        return
      }
      XCTAssertEqual(error, .sessionNotSupported)
      messageSentDone.fulfill()
    }
    waitForExpectations(timeout: 1.0) {
      XCTAssertNil($0)
    }
  }
}
