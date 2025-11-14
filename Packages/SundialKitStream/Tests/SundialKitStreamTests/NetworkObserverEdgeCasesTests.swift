//
//  NetworkObserverEdgeCasesTests.swift
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

@testable import SundialKitCore
@testable import SundialKitNetwork
@testable import SundialKitStream

@Suite("NetworkObserver Edge Cases and State Tests")
internal struct NetworkObserverEdgeCasesTests {
  // MARK: - Current State Tests

  @Test("getCurrentPath returns latest path")
  internal func getCurrentPathSnapshot() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    // Before start
    var currentPath = await observer.getCurrentPath()
    #expect(currentPath == nil)

    // After start
    await observer.start(queue: .global())

    // Give time for async path update from start()
    try? await Task.sleep(for: .milliseconds(10))

    currentPath = await observer.getCurrentPath()
    #expect(currentPath?.pathStatus == .satisfied(.wiredEthernet))

    // After update
    let newPath = MockPath(pathStatus: .satisfied(.wifi))
    monitor.sendPath(newPath)

    // Give time for async update
    try? await Task.sleep(for: .milliseconds(10))

    currentPath = await observer.getCurrentPath()
    #expect(currentPath?.pathStatus == .satisfied(.wifi))
  }

  @Test("getCurrentPingStatus returns nil when no ping configured")
  internal func getCurrentPingStatusWithoutPing() async {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let pingStatus = await observer.getCurrentPingStatus()
    #expect(pingStatus == nil)
  }

  // MARK: - Stream Cleanup Tests

  @Test("Cancel finishes all active path streams")
  internal func cancelFinishesPathStreams() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathUpdates()
    var iterator = stream.makeAsyncIterator()

    // Get first value
    _ = await iterator.next()

    // Cancel observer
    await observer.cancel()

    // Try to get next value - should complete
    let nextValue = await iterator.next()
    #expect(nextValue == nil)
  }

  @Test("Stream iteration completes after cancel")
  internal func streamCompletesAfterCancel() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let capture = TestValueCapture()

    try await confirmation("Received initial status", expectedCount: 1) { confirm in
      Task { @Sendable in
        let stream = await observer.pathStatusStream
        var count = 0
        for await _ in stream {
          count += 1
          if count == 1 {
            confirm()
          } else {
            // Should not receive values after cancel
            await capture.set(boolValue: true)
          }
        }
      }

      // Wait for initial value confirmation
      try await Task.sleep(for: .milliseconds(50))

      // Cancel observer
      await observer.cancel()

      // Give time to verify no additional values are received
      try await Task.sleep(for: .milliseconds(100))
    }

    let receivedAfterCancel = await capture.boolValue
    #expect(receivedAfterCancel != true)
  }
}
