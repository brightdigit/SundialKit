//
//  StreamContinuationManagerTests+Messaging+TypedMessage.swift
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

extension StreamContinuationManager.Messaging {
  @Suite("Typed Message Tests")
  internal struct TypedMessageTests {
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

      let manager = SundialKitStream.StreamContinuationManager()
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

      let manager = SundialKitStream.StreamContinuationManager()
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
  }
}
