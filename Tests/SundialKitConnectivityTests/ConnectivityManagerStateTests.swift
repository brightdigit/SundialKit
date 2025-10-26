//
//  ConnectivityManagerStateTests.swift
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

  @Suite("ConnectivityManager State Property Tests")
  internal struct ConnectivityManagerStateTests {
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
  }
#endif
