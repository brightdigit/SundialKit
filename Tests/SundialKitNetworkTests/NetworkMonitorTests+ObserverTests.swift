//
//  NetworkMonitorTests+ObserverTests.swift
//  SundialKit
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

extension NetworkMonitorTests {
  // MARK: - Observer Tests

  @Test("NetworkMonitor notifies observers of path status changes")
  func testObserverPathStatusNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    // Send update
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(!observer.pathStatusUpdates.isEmpty)
    #expect(observer.pathStatusUpdates.last == .satisfied(.cellular))
  }

  @Test("NetworkMonitor notifies observers of expensive changes")
  func testObserverExpensiveNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: true,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(observer.expensiveUpdates.contains(true))
  }

  @Test("NetworkMonitor notifies observers of constrained changes")
  func testObserverConstrainedNotification() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: true,
      isExpensive: false,
      pathStatus: .satisfied(.wifi)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    #expect(observer.constrainedUpdates.contains(true))
  }

  @Test("NetworkMonitor removes observers correctly")
  func testRemoveObserver() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    await monitor.removeObservers { ($0 as? TestNetworkStateObserver) === observer }

    // Send update after removal
    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    // Observer should not have received the cellular update
    let hasCellularUpdate = observer.pathStatusUpdates.contains { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }
    #expect(hasCellularUpdate == false)
  }

  @Test("NetworkMonitor allows duplicate observers")
  func testDuplicateObservers() async throws {
    let pathMonitor = MockPathMonitor(id: UUID())
    let monitor = NetworkMonitor(monitor: pathMonitor, ping: nil as NeverPing?)
    let observer = TestNetworkStateObserver()

    await monitor.addObserver(observer)
    await monitor.addObserver(observer)  // Add again (now allowed with strong references)
    monitor.start(queue: .global())

    try await Task.sleep(forMilliseconds: 300)

    let newPath = MockPath(
      isConstrained: false,
      isExpensive: false,
      pathStatus: .satisfied(.cellular)
    )
    pathMonitor.sendPath(newPath)

    try await Task.sleep(forMilliseconds: 200)

    // With strong references, duplicates receive notifications multiple times
    let cellularCount = observer.pathStatusUpdates.filter { status in
      if case .satisfied(.cellular) = status {
        return true
      }
      return false
    }.count

    #expect(cellularCount == 2)  // Observer added twice, receives notification twice
  }
}
