import Foundation
import SundialKit

import XCTest

#if canImport(Combine)
  extension WCObjectMessageTests {
    private func combineTestSendMessageReachable() {
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
      let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
        XCTAssertEqual(message[key] as? UUID, value)

        guard case let .reply(actual) = result else {
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
    }

    private func combineSendMessageAppInstalled() {
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
      let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
        XCTAssertEqual(message[key] as? UUID, value)

        guard case .applicationContext = result else {
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
    }
  }
#endif
