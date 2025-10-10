import Foundation
import XCTest

@testable import SundialKit

internal final class ConnectivityObserverPropertyTests: XCTestCase {
  internal func testIsReachablePublisher() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Reachability Changed")
      let session = MockSession()

      let newState = true
      let wcObject = ConnectivityObserver(session: session)

      let cancellable = wcObject.isReachablePublisher.sink { state in
        XCTAssertEqual(state, newState)
        expectation.fulfill()
      }
      session.isReachable = newState
      waitForExpectations(timeout: 1.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  internal func testIsPairedAppInstalledPublisher() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Installed Changed")
      let session = MockSession()

      let newState = true
      let wcObject = ConnectivityObserver(session: session)

      let cancellable = wcObject.isPairedAppInstalledPublisher.sink { state in
        XCTAssertEqual(state, newState)
        expectation.fulfill()
      }
      session.isPairedAppInstalled = newState
      waitForExpectations(timeout: 1.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  internal func testIsPairedPublisher() throws {
    #if canImport(Combine)
      #if os(iOS)
        let expectation = expectation(description: "Installed Changed")
        let session = MockSession()

        let newState = true
        let wcObject = ConnectivityObserver(session: session)

        let cancellable = wcObject.isPairedPublisher.sink { state in
          XCTAssertEqual(state, newState)
          expectation.fulfill()
        }
        session.isPaired = newState
        waitForExpectations(timeout: 1.0) { error in
          XCTAssertNil(error)
          cancellable.cancel()
        }
      #else
        throw XCTSkip("`isPairedPublisher` is not supported by this OS.")
      #endif
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  internal func testActivationStatePublisher() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "State Change Called")
      let session = MockSession()

      let newState: ActivationState = .activated
      let wcObject = ConnectivityObserver(session: session)
      let cancellable = wcObject.activationStatePublisher.sink { state in
        XCTAssertEqual(state, newState)
        expectation.fulfill()
      }
      try wcObject.activate()
      waitForExpectations(timeout: 1.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  internal func testSessionDidBecomeInactive() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "State Change Called")
      let session = MockSession()

      let newState: ActivationState = .inactive
      let wcObject = ConnectivityObserver(session: session)
      let cancellable = wcObject.activationStatePublisher.sink { state in
        XCTAssertEqual(state, newState)
        expectation.fulfill()
      }
      session.activationState = .inactive
      waitForExpectations(timeout: 1.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  internal func testSessionDidDeactivate() throws {
    #if canImport(Combine)
      let actExpectation = expectation(description: "State Change Called to Activate")
      let notExpectation = expectation(
        description: "State Change Called to Not Activated"
      )
      let session = MockSession()

      let wcObject = ConnectivityObserver(session: session)
      let cancellable = wcObject.activationStatePublisher.sink { state in
        switch state {
        case .activated:
          session.activationState = .notActivated
          actExpectation.fulfill()

        case .notActivated:
          notExpectation.fulfill()

        default:
          XCTFail("Incorrect activation state.")
        }
      }
      try session.activate()
      waitForExpectations(timeout: 1.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }
}
