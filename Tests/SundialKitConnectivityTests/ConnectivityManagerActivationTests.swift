//
// ConnectivityManagerActivationTests.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  import Testing

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  @Suite("ConnectivityManager Activation Tests")
  internal struct ConnectivityManagerActivationTests {
    @Test("Synchronous activation succeeds")
    internal func synchronousActivationSucceeds() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try (manager.activate as () throws -> Void)()
      #expect(mockSession.activationState == .activated)

      // Wait for delegate callback to propagate through async layers
      try await Task.sleep(forMilliseconds: 500)  // 0.5 seconds
      #expect(await manager.activationState == .activated)
    }

    @Test("Async activation succeeds")
    internal func asyncActivationSucceeds() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      try await manager.activate(timeout: 5)
      #expect(mockSession.activationState == .activated)

      // Wait for actor state to be updated
      try await Task.sleep(forMilliseconds: 500)  // 0.5 seconds
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
      try await Task.sleep(forMilliseconds: 500)  // 0.5 seconds

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
  }
#endif
