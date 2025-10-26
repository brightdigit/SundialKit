//
//  ConnectivityManagerObserverTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
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
      manager.addObserver(observer)

      mockSession.activationState = .activated

      // Wait for main queue notification
      try await waitUntil { await observer.lastActivationState == .activated }
    }

    @Test("Observer receives reachability changes")
    internal func observerReceivesReachabilityChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)

      mockSession.isReachable = true

      // Wait for main queue notification
      try await waitUntil { await observer.lastReachability == true }
    }

    @Test("Observer receives companion app installed changes")
    internal func observerReceivesCompanionAppInstalledChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)

      mockSession.isPairedAppInstalled = true

      // Wait for main queue notification
      try await waitUntil { await observer.lastCompanionAppInstalled == true }
    }

    #if os(iOS)
      @Test("Observer receives paired status changes on iOS")
      internal func observerReceivesPairedStatusChanges() async throws {
        let mockSession = MockSession()
        let manager = ConnectivityManager(session: mockSession)

        let observer = TestObserver()
        manager.addObserver(observer)

        mockSession.isPaired = true

        // Wait for main queue notification
        try await waitUntil { await observer.lastPairedStatus == true }
      }
    #endif

    @Test("Observer receives messages")
    internal func observerReceivesMessages() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)

      let testMessage: ConnectivityMessage = ["test": "data"]
      mockSession.receiveMessage(testMessage) { _ in }

      // Wait for main queue notification
      try await waitUntil { await observer.lastMessage?["test"] as? String == "data" }
    }

    @Test("Observer can be removed")
    internal func observerCanBeRemoved() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)
      manager.removeObserver(observer)

      mockSession.isReachable = true

      // Wait for main queue notification
      try await Task.sleep(forMilliseconds: 200)  // 0.2 seconds

      // Should not have received notification
      #expect(await observer.lastReachability == nil)
    }

    @Test("Multiple observers receive notifications")
    internal func multipleObserversReceiveNotifications() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer1 = TestObserver()
      let observer2 = TestObserver()
      manager.addObserver(observer1)
      manager.addObserver(observer2)

      mockSession.isReachable = true

      // Wait for main queue notification
      try await waitUntil { await observer1.lastReachability == true }
      #expect(await observer2.lastReachability == true)
    }
  }
#endif
