import Combine
import Foundation
import SundialKit
import SwiftUI
import XCTest

public class WCObjectTest: XCTestCase {
  public func testActivate() throws {
    let session = MockSession()
    let wcObject = WCObject(session: session)
    try wcObject.activate()
  }

  public func testActivationStatePublisher() {
    let expectation = expectation(description: "State Change Called")
    let session = MockSession()

    let newState: ActivationState = .activated
    let wcObject = WCObject(session: session)
    let cancellable = wcObject.activationStatePublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    session.activationState = newState
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }

  public func testIsReachablePublisher() {
    let expectation = expectation(description: "Reachability Changed")
    let session = MockSession()

    let newState = true
    let wcObject = WCObject(session: session)

    let cancellable = wcObject.isReachablePublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    session.isReachable = newState
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }

  public func testIsPairedAppInstalledPublisher() {
    let expectation = expectation(description: "Installed Changed")
    let session = MockSession()

    let newState = true
    let wcObject = WCObject(session: session)

    let cancellable = wcObject.isPairedAppInstalledPublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    session.isPairedAppInstalled = newState
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }

  public func testMessageReceivedPublisherMessage() {
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
  }

  public func testMessageReceivedPublisherAppContext() throws {
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
  }

  public func testReplyMessagePublisher() {
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
    let replyCancellable = wcObject.replyMessagePublisher.sink { message, result in
      XCTAssertEqual(message[key] as? UUID, value)
      guard case let .reply(actual) = result else {
        XCTFail()
        return
      }
      XCTAssertEqual(actual[replyKey] as? UUID, replyValue)
    }
    session.receiveMessage(newState, withReplyHandler: { item in
      XCTAssertEqual(item[replyKey] as? UUID, replyValue)
      expectation.fulfill()
    })
    waitForExpectations(timeout: 5.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
      replyCancellable.cancel()
    }
  }

  public func testSendMessageReachable() {
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

  public func testSendMessageAppInstalled() {
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

  public func testIsPairedPublisher() {
    let expectation = expectation(description: "Installed Changed")
    let session = MockSession()

    let newState = true
    let wcObject = WCObject(session: session)

    let cancellable = wcObject.isPairedPublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    session.isPaired = newState
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }
}
