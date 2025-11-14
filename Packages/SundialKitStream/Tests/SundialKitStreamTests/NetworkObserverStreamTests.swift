//
//  NetworkObserverStreamTests.swift
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

@Suite("NetworkObserver Stream Tests")
internal struct NetworkObserverStreamTests {
  // MARK: - Path Updates Stream Tests

  @Test("pathUpdates stream receives initial and subsequent paths")
  internal func pathUpdatesStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.pathUpdates()
    var iterator = stream.makeAsyncIterator()

    // Should receive initial path
    let firstPath = await iterator.next()
    #expect(firstPath?.pathStatus == .satisfied(.wiredEthernet))

    // Send new path update
    let newPath = MockPath(
      isConstrained: true,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    monitor.sendPath(newPath)

    // Give time for async delivery
    try await Task.sleep(for: .milliseconds(10))

    let secondPath = await iterator.next()
    #expect(secondPath?.pathStatus == .satisfied(.cellular))
    #expect(secondPath?.isConstrained == true)
    #expect(secondPath?.isExpensive == true)
  }

  @Test("pathStatusStream extracts status from paths")
  internal func pathStatusStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    try await confirmation("Received path status", expectedCount: 2) { receivedStatus in
      let capture = TestValueCapture()

      Task { @Sendable in
        let stream = await observer.pathStatusStream
        for await status in stream {
          await capture.append(pathStatus: status)
          receivedStatus()
          let count = await capture.pathStatuses.count
          if count >= 2 { break }
        }
      }

      // Wait briefly for initial status
      try await Task.sleep(for: .milliseconds(10))

      // Send new path update
      let newPath = MockPath(pathStatus: .unsatisfied(.localNetworkDenied))
      monitor.sendPath(newPath)

      // Give time for async delivery
      try await Task.sleep(for: .milliseconds(50))

      let statuses = await capture.pathStatuses
      #expect(statuses.count == 2)
      #expect(statuses[0] == .satisfied(.wiredEthernet))
      #expect(statuses[1] == .unsatisfied(.localNetworkDenied))
    }
  }

  @Test("isExpensiveStream tracks expensive status")
  internal func isExpensiveStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    try await confirmation("Received expensive status", expectedCount: 2) { receivedValue in
      let capture = TestValueCapture()

      Task { @Sendable in
        let stream = await observer.isExpensiveStream
        for await value in stream {
          await capture.append(boolValue: value)
          receivedValue()
          let count = await capture.boolValues.count
          if count >= 2 { break }
        }
      }

      // Wait briefly for initial value
      try await Task.sleep(for: .milliseconds(10))

      // Send expensive path
      let expensivePath = MockPath(isExpensive: true, pathStatus: .satisfied(.cellular))
      monitor.sendPath(expensivePath)

      // Give time for async delivery
      try await Task.sleep(for: .milliseconds(50))

      let values = await capture.boolValues
      #expect(values.count == 2)
      #expect(values[0] == false)
      #expect(values[1] == true)
    }
  }

  @Test("isConstrainedStream tracks constrained status")
  internal func isConstrainedStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    try await confirmation("Received constrained status", expectedCount: 2) { receivedValue in
      let capture = TestValueCapture()

      Task { @Sendable in
        let stream = await observer.isConstrainedStream
        for await value in stream {
          await capture.append(boolValue: value)
          receivedValue()
          let count = await capture.boolValues.count
          if count >= 2 { break }
        }
      }

      // Wait briefly for initial value
      try await Task.sleep(for: .milliseconds(10))

      // Send constrained path
      let constrainedPath = MockPath(isConstrained: true, pathStatus: .satisfied(.wifi))
      monitor.sendPath(constrainedPath)

      // Give time for async delivery
      try await Task.sleep(for: .milliseconds(50))

      let values = await capture.boolValues
      #expect(values.count == 2)
      #expect(values[0] == false)
      #expect(values[1] == true)
    }
  }

  // MARK: - Multiple Subscribers Tests

  @Test("Multiple path update subscribers receive same updates")
  internal func multiplePathSubscribers() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    // Create two subscribers
    let stream1 = await observer.pathUpdates()
    let stream2 = await observer.pathUpdates()

    var iterator1 = stream1.makeAsyncIterator()
    var iterator2 = stream2.makeAsyncIterator()

    // Both should receive initial path
    let path1First = await iterator1.next()
    let path2First = await iterator2.next()

    #expect(path1First?.pathStatus == .satisfied(.wiredEthernet))
    #expect(path2First?.pathStatus == .satisfied(.wiredEthernet))

    // Send new path
    let newPath = MockPath(pathStatus: .satisfied(.cellular))
    monitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(10))

    let path1Second = await iterator1.next()
    let path2Second = await iterator2.next()

    #expect(path1Second?.pathStatus == .satisfied(.cellular))
    #expect(path2Second?.pathStatus == .satisfied(.cellular))
  }
}
