//
//  StreamContinuationManagerActivationTests.swift
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

@Suite("StreamContinuationManager Activation Tests")
internal struct StreamContinuationManagerActivationTests {
  // MARK: - Activation Tests

  @Test("Register activation continuation succeeds")
  internal func registerActivation() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<ActivationState> { continuation in
      Task {
        await manager.registerActivation(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await value in stream {
        await capture.set(activationState: value)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldActivationState(.activated)
    await task.value

    let receivedValue = await capture.activationState
    #expect(receivedValue == .activated)
  }

  @Test("Yield activation state to multiple subscribers")
  internal func yieldActivationStateMultipleSubscribers() async throws {
    let manager = StreamContinuationManager()
    let capture = TestValueCapture()

    try await confirmation("All subscribers receive value", expectedCount: 3) { confirm in
      // Create 3 subscribers
      var consumerTasks: [Task<Void, Never>] = []
      for _ in 0..<3 {
        let id = UUID()
        let stream = AsyncStream<ActivationState> { continuation in
          Task {
            await manager.registerActivation(id: id, continuation: continuation)
          }
        }

        let task = Task { @Sendable in
          for await value in stream {
            await capture.set(activationState: value)
            confirm()
            break
          }
        }
        consumerTasks.append(task)
      }

      // Give subscribers time to set up
      try await Task.sleep(for: .milliseconds(100))

      // Yield to all subscribers
      await manager.yieldActivationState(.activated)

      // Wait for all consumers to process the value
      for task in consumerTasks {
        await task.value
      }
    }

    let receivedValue = await capture.activationState
    #expect(receivedValue == .activated)
  }

  @Test("Yield activation state with no subscribers succeeds")
  internal func yieldActivationStateNoSubscribers() async {
    let manager = StreamContinuationManager()

    // Should not crash
    await manager.yieldActivationState(.activated)
  }

  @Test("Remove activation continuation succeeds")
  internal func removeActivation() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<ActivationState> { continuation in
      Task {
        await manager.registerActivation(id: id, continuation: continuation)
      }

      continuation.onTermination = { @Sendable _ in
        Task {
          await manager.removeActivation(id: id)
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

    await manager.yieldActivationState(.activated)
    task.cancel()
    await task.value
  }

  // MARK: - Activation Completion Tests

  @Test("Yield activation completion with success")
  internal func yieldActivationCompletionSuccess() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      Task {
        await manager.registerActivationCompletion(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await result in stream {
        await capture.set(activationResult: result)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldActivationCompletion(.success(.activated))
    await task.value

    let receivedResult = await capture.activationResult
    #expect(receivedResult != nil)
    if case .success(let state) = receivedResult {
      #expect(state == .activated)
    } else {
      Issue.record("Expected success result")
    }
  }

  @Test("Yield activation completion with failure")
  internal func yieldActivationCompletionFailure() async throws {
    struct TestError: Error {}
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      Task {
        await manager.registerActivationCompletion(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await result in stream {
        await capture.set(activationResult: result)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldActivationCompletion(.failure(TestError()))
    await task.value

    let receivedResult = await capture.activationResult
    #expect(receivedResult != nil)
    if case .failure = receivedResult {
      #expect(Bool(true))
    } else {
      Issue.record("Expected failure result")
    }
  }

  @Test("Remove activation completion continuation succeeds")
  internal func removeActivationCompletion() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Result<ActivationState, any Error>> { continuation in
      Task {
        await manager.registerActivationCompletion(id: id, continuation: continuation)
      }

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

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldActivationCompletion(.success(.activated))
    task.cancel()
    await task.value
  }
}
