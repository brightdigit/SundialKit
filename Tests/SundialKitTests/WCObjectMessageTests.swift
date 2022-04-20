import Foundation
import SundialKit

import XCTest

public class WCObjectMessageTests: XCTestCase {
  public func testMessageReceivedPublisherMessage() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Message Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)

      let cancellable = wcObject.messageReceivedPublisher.sink { state in
        XCTAssertEqual(state.0[key] as? UUID, value)
        expectation.fulfill()
      }
      session.receiveMessage(newState, withReplyHandler: { item in
        print(item)
      })
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  public func testMessageReceivedPublisherAppContext() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Application Context Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)

      let cancellable = wcObject.messageReceivedPublisher.sink { state in
        XCTAssertEqual(state.0[key] as? UUID, value)
        XCTAssert(state.1.isApplicationContext)
        expectation.fulfill()
      }
      try session.updateApplicationContext(newState)
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  public func testMessageReceivedPublisherAppContextWithError() throws {
    #if canImport(Combine)
      let expected = MockError.value(UUID())
      let expectation = expectation(description: "Message Sent Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)

      session.isPairedAppInstalled = true
      session.nextApplicationContextError = expected
      let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
        XCTAssertEqual(message[key] as? UUID, value)

        guard case .failure(let actual as MockError<UUID>) = result else {
          XCTFail()
          return
        }
        XCTAssertEqual(actual, expected)

        expectation.fulfill()
      }
      wcObject.sendingMessageSubject.send(newState)
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        XCTAssertNil(session.lastAppContext)

        replyCancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  public func testReplyMessagePublisher() throws {
    #if canImport(Combine)
      let expectation = expectation(description: "Message Reply Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)
      let replyKey = UUID().uuidString
      let replyValue = UUID()
      let replyMessage = [replyKey: replyValue]
      let cancellable = wcObject.messageReceivedPublisher.sink { message, reply in
        XCTAssertEqual(message[key] as? UUID, value)
        reply.replyHandler!(replyMessage)
      }
      session.receiveMessage(newState, withReplyHandler: { item in
        XCTAssertEqual(item[replyKey] as? UUID, replyValue)
        expectation.fulfill()
      })
      waitForExpectations(timeout: 5.0) { error in
        XCTAssertNil(error)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  #if canImport(Combine)
    fileprivate func combineTestSendMessageReachable() {
      let expectation = expectation(description: "Message Sent Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)
      let replyKey = UUID().uuidString
      let replyValue = UUID()
      let replyMessage = [replyKey: replyValue]
      session.isReachable = true
      session.nextReplyResult = .success(replyMessage)
      let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
        XCTAssertEqual(message[key] as? UUID, value)

        guard case let .reply(actual) = result else {
          XCTFail()
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
  #endif

  public func testSendMessageReachable() throws {
    #if canImport(Combine)
      combineTestSendMessageReachable()
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }

  #if canImport(Combine)
    fileprivate func combineSendMessageAppInstalled() {
      let expectation = expectation(description: "Message Sent Received")
      let session = MockSession()

      let key = UUID().uuidString
      let value = UUID()
      let newState: WCMessage = [key: value]
      let wcObject = WCObject(session: session)
      let replyKey = UUID().uuidString
      let replyValue = UUID()
      let replyMessage = [replyKey: replyValue]
      session.isPairedAppInstalled = true
      session.nextReplyResult = .success(replyMessage)
      let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
        XCTAssertEqual(message[key] as? UUID, value)

        guard case .applicationContext = result else {
          XCTFail()
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
  #endif

  public func testSendMessageAppInstalled() throws {
    #if canImport(Combine)
      combineSendMessageAppInstalled()
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }
}
