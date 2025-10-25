//
//  ConnectivityManagerTests.swift
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

  // MARK: - Test Helpers

  /// Waits for a condition to become true, polling at regular intervals.
  ///
  /// - Parameters:
  ///   - timeout: Maximum time to wait in seconds (default: 5)
  ///   - pollInterval: Time between checks in nanoseconds (default: 10ms)
  ///   - condition: The condition to check
  /// - Throws: If the timeout expires before the condition becomes true
  internal func waitUntil(
    timeout: TimeInterval = 5,
    pollInterval: UInt64 = 10_000_000,
    _ condition: @escaping () async -> Bool
  ) async throws {
    let deadline = Date().addingTimeInterval(timeout)
    while Date() < deadline {
      if await condition() {
        return
      }
      try await Task.sleep(nanoseconds: pollInterval)
    }
    Issue.record("Timeout waiting for condition")
  }

  @Suite("ConnectivityManager Tests")
  internal struct ConnectivityManagerTests {
    // MARK: - Initialization Tests

    @Test("Manager initializes with default session")
    internal func initializeWithDefaultSession() async {
      let manager = ConnectivityManager()
      #expect(await manager.activationState == .notActivated)
      #expect(await !manager.isReachable)
      #expect(await !manager.isPairedAppInstalled)
    }

    @Test("Manager initializes with custom session")
    internal func initializeWithCustomSession() async {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.isPairedAppInstalled = true
      mockSession.isPaired = true

      let manager = ConnectivityManager(session: mockSession)
      #expect(await manager.activationState == .activated)
      #expect(await manager.isReachable)
      #expect(await manager.isPairedAppInstalled)
      #if os(iOS)
        #expect(await manager.isPaired)
      #endif
    }

    // MARK: - Activation Tests

    @Test("Synchronous activation succeeds")
    internal func synchronousActivationSucceeds() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try (manager.activate as () throws -> Void)()
      #expect(mockSession.activationState == .activated)

      // Wait for delegate callback to propagate through async layers
      try await Task.sleep(nanoseconds: 200_000_000)  // 1 second
      #expect(await manager.activationState == .activated)
    }

    @Test("Async activation succeeds")
    internal func asyncActivationSucceeds() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try await manager.activate(timeout: 5)
      #expect(mockSession.activationState == .activated)

      // Wait for actor state to be updated
      try await Task.sleep(nanoseconds: 200_000_000)  // 1 second
      #expect(await manager.activationState == .activated)
    }

    @Test("Async activation returns immediately if already activated")
    internal func asyncActivationReturnsIfAlreadyActivated() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      let manager = ConnectivityManager(session: mockSession)

      // Should return immediately without waiting
      try await manager.activate(timeout: 5)
      #expect(await manager.activationState == .activated)
    }

    @Test("Async activation throws on concurrent activation attempts")
    internal func asyncActivationThrowsOnConcurrentAttempts() async throws {
      // Create a special mock that doesn't auto-activate
      let mockSession = SlowMockSession()
      let manager = ConnectivityManager(session: mockSession)

      // Start first activation (will hang until we manually set state)
      let task1 = Task {
        try await manager.activate(timeout: 10)
      }

      // Give first task time to start
      try await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

      // Try second activation - should throw immediately
      do {
        try await manager.activate(timeout: 10)
        Issue.record("Expected activation to throw on concurrent attempt")
      } catch {
        #expect(error is ConnectivityError)
      }

      // Complete first activation
      mockSession.activationState = .activated
      task1.cancel()
    }

    // MARK: - State Property Tests

    @Test("Activation state updates from delegate")
    internal func activationStateUpdatesFromDelegate() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      mockSession.activationState = .activated
      try await Task.sleep(nanoseconds: 200_000_000)  // 1 second
      #expect(await manager.activationState == .activated)

      mockSession.activationState = .inactive
      try await Task.sleep(nanoseconds: 200_000_000)  // 1 second
      #expect(await manager.activationState == .inactive)

      mockSession.activationState = .notActivated
      try await Task.sleep(nanoseconds: 200_000_000)  // 1 second
      #expect(await manager.activationState == .notActivated)
    }

    @Test("Reachability updates from delegate")
    internal func reachabilityUpdatesFromDelegate() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      #expect(await !manager.isReachable)

      mockSession.isReachable = true
      try await waitUntil { await manager.isReachable }

      mockSession.isReachable = false
      try await waitUntil { await !manager.isReachable }
    }

    @Test("Paired app installed updates from delegate")
    internal func pairedAppInstalledUpdatesFromDelegate() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      #expect(await !manager.isPairedAppInstalled)

      mockSession.isPairedAppInstalled = true
      try await waitUntil { await manager.isPairedAppInstalled }

      mockSession.isPairedAppInstalled = false
      try await waitUntil { await !manager.isPairedAppInstalled }
    }

    #if os(iOS)
      @Test("Paired status updates from delegate on iOS")
      internal func pairedStatusUpdatesFromDelegate() async throws {
        let mockSession = MockSession()
        let manager = ConnectivityManager(session: mockSession)

        #expect(await !manager.isPaired)

        mockSession.isPaired = true
        try await waitUntil { await manager.isPaired }

        mockSession.isPaired = false
        try await waitUntil { await !manager.isPaired }
      }
    #endif

    // MARK: - Message Sending Tests

    @Test("Send message when reachable succeeds")
    internal func sendMessageWhenReachableSucceeds() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.nextReplyResult = .success(["response": "ok"])

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]
      let reply = try await manager.send(message: message, replyTimeout: 5)

      #expect(mockSession.lastMessageSent?["test"] as? String == "message")
      #expect(reply["response"] as? String == "ok")
    }

    @Test("Send message falls back to updateApplicationContext when not reachable")
    internal func sendMessageFallsBackToUpdateApplicationContext() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = false
      mockSession.isPairedAppInstalled = true

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]
      let reply = try await manager.send(message: message, replyTimeout: 5)

      // Should have called updateApplicationContext
      #expect(mockSession.lastAppContext?["test"] as? String == "message")
      // Reply should be empty for context updates
      #expect(reply.isEmpty)
    }

    @Test("Send message throws when companion unavailable")
    internal func sendMessageThrowsWhenCompanionUnavailable() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = false
      mockSession.isPairedAppInstalled = false

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]

      do {
        _ = try await manager.send(message: message, replyTimeout: 5)
        Issue.record("Expected send to throw when companion unavailable")
      } catch {
        #expect(error is ConnectivityError)
        if let connectivityError = error as? ConnectivityError {
          #expect(connectivityError == .companionAppNotInstalled)
        }
      }
    }

    @Test("Send message validates payload size")
    internal func sendMessageValidatesPayloadSize() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true

      let manager = ConnectivityManager(session: mockSession)

      // Create a large message that exceeds 65KB
      var largeMessage: ConnectivityMessage = [:]
      for index in 0..<10_000 {
        largeMessage["key\(index)"] = String(repeating: "x", count: 100)
      }

      do {
        _ = try await manager.send(message: largeMessage, replyTimeout: 5)
        Issue.record("Expected send to throw for oversized payload")
      } catch {
        #expect(error is ConnectivityError)
        if let connectivityError = error as? ConnectivityError {
          #expect(connectivityError == .payloadTooLarge)
        }
      }
    }

    @Test("Legacy sendMessage method works")
    internal func legacySendMessageWorks() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.nextReplyResult = .success(["reply": "data"])

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "legacy"]

      await withCheckedContinuation { continuation in
        manager.sendMessage(
          message,
          replyHandler: { reply in
            #expect(reply["reply"] as? String == "data")
            continuation.resume()
          },
          errorHandler: { error in
            Issue.record("Legacy sendMessage failed: \(error)")
            continuation.resume()
          }
        )
      }

      #expect(mockSession.lastMessageSent?["test"] as? String == "legacy")
    }

    // MARK: - Observer Tests

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
      try await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

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
