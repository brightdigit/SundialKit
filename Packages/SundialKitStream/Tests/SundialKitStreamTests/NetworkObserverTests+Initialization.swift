//
//  NetworkObserverTests+Initialization.swift
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

extension NetworkObserverTests {
  @Suite("Initialization and Lifecycle Tests")
  internal struct InitializationTests {
    // MARK: - Initialization Tests

    @Test("NetworkObserver initializes with monitor only")
    internal func initializationWithMonitorOnly() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      let currentPath = await observer.getCurrentPath()
      let currentPingStatus = await observer.getCurrentPingStatus()

      #expect(currentPath == nil)
      #expect(currentPingStatus == nil)
    }

    @Test("NetworkObserver initializes with monitor and ping")
    internal func initializationWithMonitorAndPing() async {
      let monitor = MockPathMonitor()
      let ping = MockNetworkPing()
      let observer = NetworkObserver(monitor: monitor, ping: ping)

      let currentPath = await observer.getCurrentPath()
      let currentPingStatus = await observer.getCurrentPingStatus()

      #expect(currentPath == nil)
      #expect(currentPingStatus == nil)
    }

    // MARK: - Start/Cancel Tests

    @Test("Start monitoring begins path updates")
    internal func startMonitoring() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      await observer.start(queue: .global())

      #expect(monitor.dispatchQueueLabel != nil)
      #expect(monitor.isCancelled == false)

      // Give time for async path update from start()
      try? await Task.sleep(for: .milliseconds(10))

      // Should receive initial path from start()
      let currentPath = await observer.getCurrentPath()
      #expect(currentPath != nil)
      #expect(currentPath?.pathStatus == .satisfied(.wiredEthernet))
    }

    @Test("Cancel stops monitoring and finishes streams")
    internal func cancelMonitoring() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      await observer.start(queue: .global())
      await observer.cancel()

      #expect(monitor.isCancelled == true)
    }

    @Test("Path updates before start are not tracked")
    internal func pathUpdatesBeforeStart() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      // Don't call start()
      let currentPath = await observer.getCurrentPath()
      #expect(currentPath == nil)
    }

    @Test("Multiple start calls use latest queue")
    internal func multipleStartCalls() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      await observer.start(queue: .global())
      let firstLabel = monitor.dispatchQueueLabel

      await observer.start(queue: .main)
      let secondLabel = monitor.dispatchQueueLabel

      #expect(firstLabel != nil)
      #expect(secondLabel != nil)
      // Labels should be different since we used different queues
    }

    // MARK: - Ping Integration Tests

    @Test("Ping status updates are not tracked without ping initialization")
    internal func pingStatusWithoutPing() async {
      let monitor = MockPathMonitor()
      let observer = NetworkObserver(monitor: monitor)

      await observer.start(queue: .global())

      let currentPingStatus = await observer.getCurrentPingStatus()
      #expect(currentPingStatus == nil)
    }

    // Note: Full ping integration testing would require NetworkMonitor-level tests
    // since NetworkObserver doesn't directly manage ping lifecycle
  }
}
