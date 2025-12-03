//
//  ConnectivityManagerStateTests.swift
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

  @Suite("ConnectivityManager State Property Tests")
  internal struct ConnectivityManagerStateTests {
    @Test("Activation state updates from delegate")
    internal func activationStateUpdatesFromDelegate() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      mockSession.activationState = .activated
      try await Task.sleep(forMilliseconds: 200)  // 0.2 seconds
      #expect(await manager.activationState == .activated)

      mockSession.activationState = .inactive
      try await Task.sleep(forMilliseconds: 200)  // 0.2 seconds
      #expect(await manager.activationState == .inactive)

      mockSession.activationState = .notActivated
      try await Task.sleep(forMilliseconds: 200)  // 0.2 seconds
      #expect(await manager.activationState == .notActivated)
    }

    @Test("Reachability updates from delegate")
    internal func reachabilityUpdatesFromDelegate() async throws {
      let mockSession = MockSession()
      let manager = ConnectivityManager(session: mockSession)

      #expect(await !manager.isReachable)

      mockSession.isReachable = true
      await Task.yield()  // Yield to allow unstructured Task in delegate handler to run
      #expect(await manager.isReachable)

      mockSession.isReachable = false
      await Task.yield()  // Yield to allow unstructured Task in delegate handler to run
      #expect(await !manager.isReachable)
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
