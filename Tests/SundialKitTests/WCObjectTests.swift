import Combine
import Foundation
import SundialKit

import XCTest

public class WCObjectTests: XCTestCase {
  public func testActivate() throws {
    let session = MockSession()
    let wcObject = WCObject(session: session)
    try wcObject.activate()
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

  public func testMessageReceivedPublisherAppContextWithError() throws {
    let expected = MockError.value(UUID())
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
    session.receiveMessage(newState, withReplyHandler: { item in
      XCTAssertEqual(item[replyKey] as? UUID, replyValue)
      expectation.fulfill()
    })
    waitForExpectations(timeout: 5.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
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

  public func testIsPairedPublisher() throws {
    #if os(iOS)
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
    #else
      throw XCTSkip("`isPairedPublisher` is not supported by this OS.")
    #endif
  }

  public func testActivationStatePublisher() throws {
    let expectation = expectation(description: "State Change Called")
    let session = MockSession()

    let newState: ActivationState = .activated
    let wcObject = WCObject(session: session)
    let cancellable = wcObject.activationStatePublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    try session.activate()
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }

  public func testSessionDidBecomeInactive() {
    let expectation = expectation(description: "State Change Called")
    let session = MockSession()

    let newState: ActivationState = .inactive
    let wcObject = WCObject(session: session)
    let cancellable = wcObject.activationStatePublisher.sink { state in
      XCTAssertEqual(state, newState)
      expectation.fulfill()
    }
    session.activationState = .inactive
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }

  public func testSessionDidDeactivate() throws {
    let actExpectation = expectation(description: "State Change Called to Activate")
    let notExpectation = expectation(description: "State Change Called to Not Activated")
    let session = MockSession()

    let wcObject = WCObject(session: session)
    let cancellable = wcObject.activationStatePublisher.sink { state in
      switch state {
      case .activated:
        session.activationState = .notActivated
        actExpectation.fulfill()

      case .notActivated:
        notExpectation.fulfill()

      default:
        XCTFail()
      }
    }
    try session.activate()
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      cancellable.cancel()
    }
  }
}
