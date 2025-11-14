//
//  StreamContinuationManagerMessagingTests.swift
//  SundialKitStream
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import Testing

@testable import SundialKitConnectivity
@testable import SundialKitCore
@testable import SundialKitStream

@Suite("StreamContinuationManager Messaging Tests")
internal struct StreamContinuationManagerMessagingTests {
  // MARK: - Message Received Tests

  @Test("Yield message received")
  internal func yieldMessageReceived() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<ConnectivityReceiveResult> { continuation in
      Task {
        await manager.registerMessageReceived(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await message in stream {
        await capture.set(message: message)
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let result = ConnectivityReceiveResult(
      message: testMessage,
      context: .applicationContext
    )

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldMessageReceived(result)
    await task.value

    let receivedMessage = await capture.message
    #expect(receivedMessage != nil)
    #expect(receivedMessage?.message["key"] as? String == "value")
  }

  @Test("Remove message received continuation succeeds")
  internal func removeMessageReceived() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<ConnectivityReceiveResult> { continuation in
      Task {
        await manager.registerMessageReceived(id: id, continuation: continuation)
      }

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeMessageReceived(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let result = ConnectivityReceiveResult(
      message: testMessage,
      context: .applicationContext
    )

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldMessageReceived(result)
    task.cancel()
    await task.value
  }

  // MARK: - Typed Message Tests

  @Test("Yield typed message")
  internal func yieldTypedMessage() async throws {
    struct TestMessage: Messagable {
      static let key: String = "test"
      let value: String

      init(from message: ConnectivityMessage) {
        self.value = message["value"] as? String ?? ""
      }

      func parameters() -> ConnectivityMessage {
        ["value": value]
      }
    }

    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<any Messagable> { continuation in
      Task {
        await manager.registerTypedMessage(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await message in stream {
        await capture.set(typedMessage: message)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    let testMessage = TestMessage(from: ["value": "test"])
    await manager.yieldTypedMessage(testMessage)
    _ = await task.value

    let receivedMessage = await capture.typedMessage
    #expect(receivedMessage != nil)
    #expect((receivedMessage as? TestMessage)?.value == "test")
  }

  @Test("Remove typed message continuation succeeds")
  internal func removeTypedMessage() async throws {
    struct TestMessage: Messagable {
      static let key: String = "test"

      init(from message: ConnectivityMessage) {}
      func parameters() -> ConnectivityMessage { [:] }
    }

    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<any Messagable> { continuation in
      Task {
        await manager.registerTypedMessage(id: id, continuation: continuation)
      }

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeTypedMessage(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    let testMessage = TestMessage(from: [:])
    await manager.yieldTypedMessage(testMessage)
    task.cancel()
    _ = await task.value
  }

  // MARK: - Send Result Tests

  @Test("Yield send result")
  internal func yieldSendResult() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<ConnectivitySendResult> { continuation in
      Task {
        await manager.registerSendResult(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await result in stream {
        // Store the result using message field
        await capture.set(message: ConnectivityReceiveResult(message: result.message, context: .applicationContext))
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let sendResult = ConnectivitySendResult(
      message: testMessage,
      context: .applicationContext(transport: .dictionary)
    )

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldSendResult(sendResult)
    _ = await task.value

    let receivedResult = await capture.message
    #expect(receivedResult != nil)
    #expect(receivedResult?.message["key"] as? String == "value")
  }

  @Test("Remove send result continuation succeeds")
  internal func removeSendResult() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<ConnectivitySendResult> { continuation in
      Task {
        await manager.registerSendResult(id: id, continuation: continuation)
      }

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeSendResult(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let sendResult = ConnectivitySendResult(
      message: testMessage,
      context: .applicationContext(transport: .dictionary)
    )

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldSendResult(sendResult)
    task.cancel()
    _ = await task.value
  }
}
