//
//  ConnectivityManagerActivationTests.swift
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
