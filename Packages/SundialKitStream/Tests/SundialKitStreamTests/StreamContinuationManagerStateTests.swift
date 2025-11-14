//
//  StreamContinuationManagerStateTests.swift
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

@Suite("StreamContinuationManager State Property Tests")
internal struct StreamContinuationManagerStateTests {
  // MARK: - Reachability Tests

  @Test("Yield reachability to subscribers")
  internal func yieldReachability() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerReachability(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await value in stream {
        await capture.set(boolValue: value)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldReachability(true)
    await task.value

    let receivedValue = await capture.boolValue
    #expect(receivedValue == true)
  }

  @Test("Yield reachability transitions")
  internal func yieldReachabilityTransitions() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerReachability(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await value in stream {
        await capture.append(boolValue: value)
        let count = await capture.boolValues.count
        if count >= 3 {
          break
        }
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldReachability(true)
    await manager.yieldReachability(false)
    await manager.yieldReachability(true)

    await task.value

    let receivedValues = await capture.boolValues
    #expect(receivedValues == [true, false, true])
  }

  @Test("Remove reachability continuation succeeds")
  internal func removeReachability() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerReachability(id: id, continuation: continuation)
      }

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

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldReachability(true)
    task.cancel()
    await task.value
  }

  // MARK: - Paired App Installed Tests

  @Test("Yield paired app installed status")
  internal func yieldPairedAppInstalled() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerPairedAppInstalled(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await value in stream {
        await capture.set(boolValue: value)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldPairedAppInstalled(true)
    await task.value

    let receivedValue = await capture.boolValue
    #expect(receivedValue == true)
  }

  @Test("Remove paired app installed continuation succeeds")
  internal func removePairedAppInstalled() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerPairedAppInstalled(id: id, continuation: continuation)
      }

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

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldPairedAppInstalled(true)
    task.cancel()
    await task.value
  }

  // MARK: - Paired Tests (iOS-specific)

  @Test("Yield paired status")
  internal func yieldPaired() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()
    let capture = TestValueCapture()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerPaired(id: id, continuation: continuation)
      }
    }

    let task = Task { @Sendable in
      for await value in stream {
        await capture.set(boolValue: value)
        break
      }
    }

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldPaired(true)
    await task.value

    let receivedValue = await capture.boolValue
    #expect(receivedValue == true)
  }

  @Test("Remove paired continuation succeeds")
  internal func removePaired() async throws {
    let manager = StreamContinuationManager()
    let id = UUID()

    let stream = AsyncStream<Bool> { continuation in
      Task {
        await manager.registerPaired(id: id, continuation: continuation)
      }

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

    // Give subscriber time to set up
    try await Task.sleep(for: .milliseconds(50))

    await manager.yieldPaired(true)
    task.cancel()
    await task.value
  }
}
