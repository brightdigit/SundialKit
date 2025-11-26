//
// ConnectivityManagerInitializationTests.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  import Testing

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  @Suite("ConnectivityManager Initialization Tests")
  internal struct ConnectivityManagerInitializationTests {
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
  }
#endif
