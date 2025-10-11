import Foundation
import XCTest

@testable import SundialKit

internal final class ConnectivityObserverMessageTests: XCTestCase {
  // swiftlint:disable:next function_body_length
  internal func testCombineSendMessageReachable() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Message Sent Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: ConnectivityMessage = [key: value]
      let wcObject = ConnectivityObserver(session: session)
      let replyKey = UUID().uuidString
      let replyValue = UUID()
      let replyMessage = [replyKey: replyValue]
      session.isReachable = true
      session.nextReplyResult = .success(replyMessage)
      let replyCancellable = wcObject.replyMessagePublisher.sink { response in
        XCTAssertEqual(response.message[key] as? UUID, value)

        guard case .reply(let actual) = response.context else {
          XCTFail("Missing result")
          return
        }
        XCTAssertEqual(actual[replyKey] as? UUID, replyValue)

        expectation.fulfill()
      }
      wcObject.sendingMessageSubject.send(newState)
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        XCTAssertEqual(session.lastMessageSent?[key] as? UUID, value)

        replyCancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  // swiftlint:disable:next function_body_length
  internal func testCombineSendMessageAppInstalled() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Message Sent Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: ConnectivityMessage = [key: value]
      let wcObject = ConnectivityObserver(session: session)
      let replyKey = UUID().uuidString
      let replyValue = UUID()
      let replyMessage = [replyKey: replyValue]
      session.isPairedAppInstalled = true
      session.nextReplyResult = .success(replyMessage)
      let replyCancellable = wcObject.replyMessagePublisher.sink { response in
        XCTAssertEqual(response.message[key] as? UUID, value)

        guard case .applicationContext = response.context else {
          XCTFail("Missing application context")
          return
        }

        expectation.fulfill()
      }
      wcObject.sendingMessageSubject.send(newState)
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        XCTAssertEqual(session.lastAppContext?[key] as? UUID, value)

        replyCancellable.cancel()
      }

    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }
}
