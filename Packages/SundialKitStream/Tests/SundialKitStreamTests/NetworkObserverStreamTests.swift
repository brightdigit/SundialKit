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

    let stream = await observer.pathStatusStream
    var iterator = stream.makeAsyncIterator()

    // Should receive initial status
    let firstStatus = await iterator.next()
    #expect(firstStatus == .satisfied(.wiredEthernet))

    // Send new path update
    let newPath = MockPath(pathStatus: .unsatisfied(.localNetworkDenied))
    monitor.sendPath(newPath)

    try await Task.sleep(for: .milliseconds(10))

    let secondStatus = await iterator.next()
    #expect(secondStatus == .unsatisfied(.localNetworkDenied))
  }

  @Test("isExpensiveStream tracks expensive status")
  internal func isExpensiveStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.isExpensiveStream
    var iterator = stream.makeAsyncIterator()

    // Initial path is not expensive
    let firstValue = await iterator.next()
    #expect(firstValue == false)

    // Send expensive path
    let expensivePath = MockPath(isExpensive: true, pathStatus: .satisfied(.cellular))
    monitor.sendPath(expensivePath)

    try await Task.sleep(for: .milliseconds(10))

    let secondValue = await iterator.next()
    #expect(secondValue == true)
  }

  @Test("isConstrainedStream tracks constrained status")
  internal func isConstrainedStream() async throws {
    let monitor = MockPathMonitor()
    let observer = NetworkObserver(monitor: monitor)

    await observer.start(queue: .global())

    let stream = await observer.isConstrainedStream
    var iterator = stream.makeAsyncIterator()

    // Initial path is not constrained
    let firstValue = await iterator.next()
    #expect(firstValue == false)

    // Send constrained path
    let constrainedPath = MockPath(isConstrained: true, pathStatus: .satisfied(.wifi))
    monitor.sendPath(constrainedPath)

    try await Task.sleep(for: .milliseconds(10))

    let secondValue = await iterator.next()
    #expect(secondValue == true)
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
