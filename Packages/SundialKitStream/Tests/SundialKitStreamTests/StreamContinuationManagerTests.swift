//
//  StreamContinuationManagerTests.swift
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

@Suite("StreamContinuationManager Tests")
internal struct StreamContinuationManagerTests {
  // MARK: - Activation Tests

  @Test("Register activation continuation succeeds")
  internal func registerActivation() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedValue: ActivationState?

    let stream = AsyncStream<ActivationState> { continuation in
      await manager.registerActivation(id: id, continuation: continuation)
    }

    // Create task to consume stream
    let task = Task {
      for await value in stream {
        receivedValue = value
        break
      }
    }

    // Yield a value
    await manager.yieldActivationState(.activated)

    // Wait for consumption
    await task.value

    #expect(receivedValue == .activated)
  }

  @Test("Yield activation state to multiple subscribers")
  internal func yieldActivationStateMultipleSubscribers() async {
    let manager = StreamContinuationManager()
    var receivedValues: [ActivationState] = []

    await confirmation("All subscribers receive value", expectedCount: 3) { confirm in
      // Create 3 subscribers
      for _ in 0..<3 {
        let id = UUID()
        let stream = AsyncStream<ActivationState> { continuation in
          await manager.registerActivation(id: id, continuation: continuation)
        }

        Task {
          for await value in stream {
            receivedValues.append(value)
            confirm()
            break
          }
        }
      }

      // Give subscribers time to set up
      try? await Task.sleep(for: .milliseconds(100))

      // Yield to all subscribers
      await manager.yieldActivationState(.activated)
    }

    #expect(receivedValues.count == 3)
    #expect(receivedValues.allSatisfy { $0 == .activated })
  }

  @Test("Yield activation state with no subscribers succeeds")
  internal func yieldActivationStateNoSubscribers() async {
    let manager = StreamContinuationManager()

    // Should not crash
    await manager.yieldActivationState(.activated)
  }

  @Test("Remove activation continuation succeeds")
  internal func removeActivation() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedCount = 0

    let stream = AsyncStream<ActivationState> { continuation in
      await manager.registerActivation(id: id, continuation: continuation)

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeActivation(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        receivedCount += 1
      }
    }

    // Yield one value
    await manager.yieldActivationState(.activated)

    // Small delay to process
    try? await Task.sleep(for: .milliseconds(50))

    // Cancel task to trigger onTermination
    task.cancel()
    await task.value

    #expect(receivedCount == 1)
  }

  // MARK: - Activation Completion Tests

  @Test("Yield activation completion with success")
  internal func yieldActivationCompletionSuccess() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedResult: Result<ActivationState, any Error>?

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      await manager.registerActivationCompletion(id: id, continuation: continuation)
    }

    let task = Task {
      for await result in stream {
        receivedResult = result
        break
      }
    }

    await manager.yieldActivationCompletion(.success(.activated))
    await task.value

    #expect(receivedResult != nil)
    if case .success(let state) = receivedResult {
      #expect(state == .activated)
    } else {
      Issue.record("Expected success result")
    }
  }

  @Test("Yield activation completion with failure")
  internal func yieldActivationCompletionFailure() async {
    struct TestError: Error {}
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedResult: Result<ActivationState, any Error>?

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      Task {
        await manager.registerActivationCompletion(id: id, continuation: continuation)
      }
    }

    let task = Task {
      for await result in stream {
        receivedResult = result
        break
      }
    }

    await manager.yieldActivationCompletion(.failure(TestError()))
    _ = await task.value

    #expect(receivedResult != nil)
    if case .failure = receivedResult {
      #expect(Bool(true))
    } else {
      Issue.record("Expected failure result")
    }
  }

  @Test("Remove activation completion continuation succeeds")
  internal func removeActivationCompletion() async {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      await manager.registerActivationCompletion(id: id, continuation: continuation)

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeActivationCompletion(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    await manager.yieldActivationCompletion(.success(.activated))
    task.cancel()
    await task.value
  }

  // MARK: - Reachability Tests

  @Test("Yield reachability to subscribers")
  internal func yieldReachability() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedValue: Bool?

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerReachability(id: id, continuation: continuation)
    }

    let task = Task {
      for await value in stream {
        receivedValue = value
        break
      }
    }

    await manager.yieldReachability(true)
    await task.value

    #expect(receivedValue == true)
  }

  @Test("Yield reachability transitions")
  internal func yieldReachabilityTransitions() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedValues: [Bool] = []

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerReachability(id: id, continuation: continuation)
    }

    let task = Task {
      for await value in stream {
        receivedValues.append(value)
        if receivedValues.count >= 3 {
          break
        }
      }
    }

    await manager.yieldReachability(true)
    await manager.yieldReachability(false)
    await manager.yieldReachability(true)

    await task.value

    #expect(receivedValues == [true, false, true])
  }

  @Test("Remove reachability continuation succeeds")
  internal func removeReachability() async {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerReachability(id: id, continuation: continuation)

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeReachability(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    await manager.yieldReachability(true)
    task.cancel()
    await task.value
  }

  // MARK: - Paired App Installed Tests

  @Test("Yield paired app installed status")
  internal func yieldPairedAppInstalled() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedValue: Bool?

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerPairedAppInstalled(id: id, continuation: continuation)
    }

    let task = Task {
      for await value in stream {
        receivedValue = value
        break
      }
    }

    await manager.yieldPairedAppInstalled(true)
    await task.value

    #expect(receivedValue == true)
  }

  @Test("Remove paired app installed continuation succeeds")
  internal func removePairedAppInstalled() async {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerPairedAppInstalled(id: id, continuation: continuation)

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removePairedAppInstalled(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    await manager.yieldPairedAppInstalled(true)
    task.cancel()
    await task.value
  }

  // MARK: - Paired Tests (iOS-specific)

  @Test("Yield paired status")
  internal func yieldPaired() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedValue: Bool?

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerPaired(id: id, continuation: continuation)
    }

    let task = Task {
      for await value in stream {
        receivedValue = value
        break
      }
    }

    await manager.yieldPaired(true)
    await task.value

    #expect(receivedValue == true)
  }

  @Test("Remove paired continuation succeeds")
  internal func removePaired() async {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      await manager.registerPaired(id: id, continuation: continuation)

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removePaired(id: id)
        }
      }
    }

    let task = Task {
      for await _ in stream {
        break
      }
    }

    await manager.yieldPaired(true)
    task.cancel()
    await task.value
  }

  // MARK: - Message Received Tests

  @Test("Yield message received")
  internal func yieldMessageReceived() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedMessage: ConnectivityReceiveResult?

    let stream = AsyncStream<ConnectivityReceiveResult> { continuation in
      await manager.registerMessageReceived(id: id, continuation: continuation)
    }

    let task = Task {
      for await message in stream {
        receivedMessage = message
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let result = ConnectivityReceiveResult(
      message: testMessage,
      context: .applicationContext
    )

    await manager.yieldMessageReceived(result)
    await task.value

    #expect(receivedMessage != nil)
    #expect(receivedMessage?.message["key"] as? String == "value")
  }

  @Test("Remove message received continuation succeeds")
  internal func removeMessageReceived() async {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<ConnectivityReceiveResult> { continuation in
      await manager.registerMessageReceived(id: id, continuation: continuation)

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

    await manager.yieldMessageReceived(result)
    task.cancel()
    await task.value
  }

  // MARK: - Typed Message Tests

  @Test("Yield typed message")
  internal func yieldTypedMessage() async {
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
    var receivedMessage: (any Messagable)?

    let stream = AsyncStream<any Messagable> { continuation in
      Task {
        await manager.registerTypedMessage(id: id, continuation: continuation)
      }
    }

    let task = Task {
      for await message in stream {
        receivedMessage = message
        break
      }
    }

    let testMessage = TestMessage(from: ["value": "test"])
    await manager.yieldTypedMessage(testMessage)
    _ = await task.value

    #expect(receivedMessage != nil)
    #expect((receivedMessage as? TestMessage)?.value == "test")
  }

  @Test("Remove typed message continuation succeeds")
  internal func removeTypedMessage() async {
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

    let testMessage = TestMessage(from: [:])
    await manager.yieldTypedMessage(testMessage)
    task.cancel()
    _ = await task.value
  }

  // MARK: - Send Result Tests

  @Test("Yield send result")
  internal func yieldSendResult() async {
    let manager = StreamContinuationManager()
    let id = UUID()
    var receivedResult: ConnectivitySendResult?

    let stream = AsyncStream<ConnectivitySendResult> { continuation in
      Task {
        await manager.registerSendResult(id: id, continuation: continuation)
      }
    }

    let task = Task {
      for await result in stream {
        receivedResult = result
        break
      }
    }

    let testMessage: ConnectivityMessage = ["key": "value"]
    let sendResult = ConnectivitySendResult(
      message: testMessage,
      context: .applicationContext(transport: .dictionary)
    )

    await manager.yieldSendResult(sendResult)
    _ = await task.value

    #expect(receivedResult != nil)
    #expect(receivedResult?.message["key"] as? String == "value")
  }

  @Test("Remove send result continuation succeeds")
  internal func removeSendResult() async {
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

    await manager.yieldSendResult(sendResult)
    task.cancel()
    _ = await task.value
  }

  // MARK: - Concurrent Operations Tests

  @Test("Concurrent yielding to same stream type")
  internal func concurrentYielding() async {
    let manager = StreamContinuationManager()
    var receivedValues: [ActivationState] = []

    await confirmation("All values received", expectedCount: 10) { confirm in
      let id = UUID()
      let stream = AsyncStream<ActivationState> { continuation in
        Task {
          await manager.registerActivation(id: id, continuation: continuation)
        }
      }

      Task {
        for await value in stream {
          receivedValues.append(value)
          confirm()
          if receivedValues.count >= 10 {
            break
          }
        }
      }

      // Give subscriber time to set up
      try? await Task.sleep(for: .milliseconds(50))

      // Yield multiple values concurrently
      await withTaskGroup(of: Void.self) { group in
        for _ in 0..<10 {
          group.addTask {
            await manager.yieldActivationState(.activated)
          }
        }
      }
    }

    #expect(receivedValues.count == 10)
  }

  @Test("Multiple stream types active simultaneously")
  internal func multipleStreamTypes() async {
    let manager = StreamContinuationManager()
    var activationReceived = false
    var reachabilityReceived = false
    var pairedAppInstalledReceived = false

    await withTaskGroup(of: Void.self) { group in
      // Activation stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<ActivationState> { continuation in
          Task {
            await manager.registerActivation(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          activationReceived = true
          break
        }
      }

      // Reachability stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task {
            await manager.registerReachability(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          reachabilityReceived = true
          break
        }
      }

      // Paired app installed stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task {
            await manager.registerPairedAppInstalled(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          pairedAppInstalledReceived = true
          break
        }
      }

      // Give subscribers time to set up
      try? await Task.sleep(for: .milliseconds(100))

      // Yield to all streams
      await manager.yieldActivationState(.activated)
      await manager.yieldReachability(true)
      await manager.yieldPairedAppInstalled(true)
    }

    #expect(activationReceived)
    #expect(reachabilityReceived)
    #expect(pairedAppInstalledReceived)
  }
}
