@testable import SundialKit
import XCTest

public final class NeverConnectivitySessionTests: XCTestCase {
  private let session = NeverConnectivitySession()

  public func testDelegateGet() {
    XCTAssertNil(session.delegate)
  }

  public func testIsReachable() {
    XCTAssertFalse(session.isReachable)
  }

  public func testIsPaired() {
    XCTAssertFalse(session.isPaired)
  }

  public func testIsPairedAppInstalled() {
    XCTAssertFalse(session.isPairedAppInstalled)
  }

  public func testActivationState() {
    XCTAssertEqual(session.activationState, .notActivated)
  }

  public func testActivate() {
    XCTAssertThrowsError(try session.activate()) { error in
      XCTAssertEqual(error as? SundialError, SundialError.sessionNotSupported)
    }
  }

  public func testUpdateApplicationContext() {
    XCTAssertThrowsError(try session.updateApplicationContext(.init())) { error in
      XCTAssertEqual(error as? SundialError, SundialError.sessionNotSupported)
    }
  }

  public func testSendMessage() {
    let messageSentDone = expectation(description: "Message Sent Done")
    session.sendMessage(.init()) { result in
      guard case let .failure(error as SundialError) = result else {
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
