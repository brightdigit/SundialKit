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

  @Suite("ConnectivityManager Tests")
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  internal struct ConnectivityManagerTests {
    // MARK: - Initialization Tests

    @Test("Manager initializes with default session")
    internal func initializeWithDefaultSession() {
      let manager = ConnectivityManager()
      #expect(manager.activationState == .notActivated)
      #expect(!manager.isReachable)
      #expect(!manager.isPairedAppInstalled)
    }

    @Test("Manager initializes with custom session")
    internal func initializeWithCustomSession() {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.isPairedAppInstalled = true
      mockSession.isPaired = true

      let manager = ConnectivityManager(session: mockSession)
      #expect(manager.activationState == .activated)
      #expect(manager.isReachable)
      #expect(manager.isPairedAppInstalled)
      #if os(iOS)
        #expect(manager.isPaired)
      #endif
    }

    // MARK: - Activation Tests

    @Test("Synchronous activation succeeds")
    internal func synchronousActivationSucceeds() throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try manager.activate()
      #expect(mockSession.activationState == .activated)
      #expect(manager.activationState == .activated)
    }

    @Test("Async activation succeeds")
    internal func asyncActivationSucceeds() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try await manager.activate(timeout: 5)
      #expect(mockSession.activationState == .activated)
      #expect(manager.activationState == .activated)
    }

    @Test("Async activation returns immediately if already activated")
    internal func asyncActivationReturnsIfAlreadyActivated() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      let manager = ConnectivityManager(session: mockSession)

      // Should return immediately without waiting
      try await manager.activate(timeout: 5)
      #expect(manager.activationState == .activated)
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
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

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
    internal func activationStateUpdatesFromDelegate() {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      mockSession.activationState = .activated
      #expect(manager.activationState == .activated)

      mockSession.activationState = .inactive
      #expect(manager.activationState == .inactive)

      mockSession.activationState = .notActivated
      #expect(manager.activationState == .notActivated)
    }

    @Test("Reachability updates from delegate")
    internal func reachabilityUpdatesFromDelegate() {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      #expect(!manager.isReachable)

      mockSession.isReachable = true
      #expect(manager.isReachable)

      mockSession.isReachable = false
      #expect(!manager.isReachable)
    }

    @Test("Paired app installed updates from delegate")
    internal func pairedAppInstalledUpdatesFromDelegate() {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      #expect(!manager.isPairedAppInstalled)

      mockSession.isPairedAppInstalled = true
      #expect(manager.isPairedAppInstalled)

      mockSession.isPairedAppInstalled = false
      #expect(!manager.isPairedAppInstalled)
    }

    #if os(iOS)
      @Test("Paired status updates from delegate on iOS")
      internal func pairedStatusUpdatesFromDelegate() {
        let mockSession = MockSession()
        let manager = ConnectivityManager(session: mockSession)

        #expect(!manager.isPaired)

        mockSession.isPaired = true
        #expect(manager.isPaired)

        mockSession.isPaired = false
        #expect(!manager.isPaired)
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
      for index in 0..<10000 {
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
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      #expect(observer.lastActivationState == .activated)
    }

    @Test("Observer receives reachability changes")
    internal func observerReceivesReachabilityChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)

      mockSession.isReachable = true

      // Wait for main queue notification
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      #expect(observer.lastReachability == true)
    }

    @Test("Observer receives companion app installed changes")
    internal func observerReceivesCompanionAppInstalledChanges() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      let observer = TestObserver()
      manager.addObserver(observer)

      mockSession.isPairedAppInstalled = true

      // Wait for main queue notification
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      #expect(observer.lastCompanionAppInstalled == true)
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
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        #expect(observer.lastPairedStatus == true)
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
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      #expect(observer.lastMessage?["test"] as? String == "data")
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
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      // Should not have received notification
      #expect(observer.lastReachability == nil)
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
      try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

      #expect(observer1.lastReachability == true)
      #expect(observer2.lastReachability == true)
    }
  }

  // MARK: - Test Helper Classes

  /// Mock session that doesn't auto-activate to test slow activation scenarios
  internal final class SlowMockSession: ConnectivitySession, @unchecked Sendable {
    internal var lastMessageSent: ConnectivityMessage?
    internal var lastAppContext: ConnectivityMessage?
    internal var nextReplyResult: Result<ConnectivityMessage, any Error>?
    internal var nextApplicationContextError: (any Error)?
    internal var isPaired = false
    internal var delegate: (any ConnectivitySessionDelegate)?
    internal var isReachable = false
    internal var isPairedAppInstalled = false

    internal var activationState: ActivationState = .notActivated {
      didSet {
        delegate?.session(self, activationDidCompleteWith: activationState, error: nil)
      }
    }

    internal func activate() throws {
      // Don't automatically change state - tests will do this manually
    }

    internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
      if let nextApplicationContextError = nextApplicationContextError {
        throw nextApplicationContextError
      }
      lastAppContext = context
    }

    internal func sendMessage(
      _ message: ConnectivityMessage,
      _ replyHandler: @escaping (Result<ConnectivityMessage, any Error>) -> Void
    ) {
      lastMessageSent = message
      replyHandler(nextReplyResult ?? .success([:]))
    }

    internal func sendMessageData(
      _ data: Data,
      _ completion: @escaping (Result<Data, any Error>) -> Void
    ) {
      completion(.success(Data()))
    }
  }

  internal final class TestObserver: ConnectivityStateObserver {
    internal var lastActivationState: ActivationState?
    internal var lastReachability: Bool?
    internal var lastCompanionAppInstalled: Bool?
    internal var lastPairedStatus: Bool?
    internal var lastMessage: ConnectivityMessage?
    internal var lastContext: ConnectivityMessage?

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeActivationState activationState: ActivationState
    ) {
      lastActivationState = activationState
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeReachability isReachable: Bool
    ) {
      lastReachability = isReachable
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeCompanionAppInstalled isInstalled: Bool
    ) {
      lastCompanionAppInstalled = isInstalled
    }

    #if os(iOS)
      internal func connectivityManager(
        _: ConnectivityManager,
        didChangePairedStatus isPaired: Bool
      ) {
        lastPairedStatus = isPaired
      }
    #endif

    internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveMessage message: ConnectivityMessage
    ) {
      lastMessage = message
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveApplicationContext context: ConnectivityMessage
    ) {
      lastContext = context
    }
  }
#endif
