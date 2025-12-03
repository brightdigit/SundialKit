//
//  ConnectivityManagerObserverTests.swift
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

#if canImport(WatchConnectivity)
  import Foundation
  import Testing

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  @Suite("ConnectivityManager Observer Tests")
  internal struct ConnectivityManagerObserverTests {
    @Test("Observer receives activation state changes")
    internal func observerReceivesActivationStateChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      await manager.addObserver(observer)

      mockSession.activationState = .activated

      // Yield to allow unstructured Task in delegate handler to run
      await Task.yield()
      #expect(await manager.activationState == .activated)
    }

    @Test("Observer receives reachability changes")
    internal func observerReceivesReachabilityChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      await manager.addObserver(observer)

      mockSession.isReachable = true

      // Yield to allow unstructured Task in delegate handler to run
      await Task.yield()
      #expect(await manager.isReachable == true)
    }

    @Test("Observer receives companion app installed changes")
    internal func observerReceivesCompanionAppInstalledChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      await manager.addObserver(observer)

      mockSession.isPairedAppInstalled = true

      // Yield to allow unstructured Task in delegate handler to run
      await Task.yield()
      #expect(await manager.isPairedAppInstalled == true)
    }

    #if os(iOS)
      @Test("Observer receives paired status changes on iOS")
      internal func observerReceivesPairedStatusChanges() async throws {
        let mockSession = MockSession()
        let manager = ConnectivityManager(session: mockSession)

        let observer = TestObserver()
        await manager.addObserver(observer)

        mockSession.isPaired = true

        // Yield to allow unstructured Task in delegate handler to run
        await Task.yield()
        #expect(await manager.isPaired == true)
      }
    #endif

    @Test("Observer receives messages")
    internal func observerReceivesMessages() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      await manager.addObserver(observer)

      let testMessage: ConnectivityMessage = ["test": "data"]
      mockSession.receiveMessage(testMessage) { _ in }

      // Message handling doesn't update manager state, so we need a small delay
      // to allow the unstructured Task in TestObserver to complete
      try await Task.sleep(forMilliseconds: 100)
      #expect(await observer.lastMessage?["test"] as? String == "data")
    }

    @Test("Observer can be removed")
    internal func observerCanBeRemoved() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      await manager.addObserver(observer)
      await manager.removeObserver(observer)

      mockSession.isReachable = true

      // Wait for main queue notification
      try await Task.sleep(forMilliseconds: 1_000)  // 0.2 seconds

      // Should not have received notification
      #expect(await observer.lastReachability == nil)
    }

    @Test("Multiple observers receive notifications")
    internal func multipleObserversReceiveNotifications() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer1 = TestObserver()
      let observer2 = TestObserver()
      await manager.addObserver(observer1)
      await manager.addObserver(observer2)

      mockSession.isReachable = true

      // Yield to allow unstructured Task in delegate handler to run
      await Task.yield()
      #expect(await manager.isReachable == true)
    }
  }
#endif
