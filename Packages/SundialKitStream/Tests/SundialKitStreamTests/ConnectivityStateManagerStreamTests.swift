//
//  ConnectivityStateManagerStreamTests.swift
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

@testable import SundialKitConnectivity
@testable import SundialKitCore
@testable import SundialKitStream

@Suite("ConnectivityStateManager Stream Notification Tests")
internal struct ConnectivityStateManagerStreamTests {
  // MARK: - Stream Notification Integration Tests
  // Note: These tests verify that state changes trigger notifications via continuationManager

  @Test("Handle activation triggers all stream notifications")
  internal func handleActivationTriggersNotifications() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up actor-isolated state capture
    let capture = TestValueCapture()

    // Create streams with proper Task wrapping
    let activationId = UUID()
    let reachabilityId = UUID()
    let pairedAppInstalledId = UUID()

    let activationStream = AsyncStream<ActivationState> { continuation in
      Task.detached {
        await continuationManager.registerActivation(id: activationId, continuation: continuation)
      }
    }

    let reachabilityStream = AsyncStream<Bool> { continuation in
      Task.detached {
        await continuationManager.registerReachability(
          id: reachabilityId,
          continuation: continuation
        )
      }
    }

    let pairedAppInstalledStream = AsyncStream<Bool> { continuation in
      Task.detached {
        await continuationManager.registerPairedAppInstalled(
          id: pairedAppInstalledId,
          continuation: continuation
        )
      }
    }

    // Consume streams with @Sendable closures
    Task { @Sendable in
      for await state in activationStream {
        await capture.set(activationState: state)
        break
      }
    }

    Task { @Sendable in
      for await isReachable in reachabilityStream {
        await capture.set(reachability: isReachable)
        break
      }
    }

    Task { @Sendable in
      for await isPairedAppInstalled in pairedAppInstalledStream {
        await capture.set(pairedAppInstalled: isPairedAppInstalled)
        break
      }
    }

    // Give streams time to register
    try? await Task.sleep(for: .milliseconds(100))

    // Trigger activation
    session.isReachable = true
    session.isPairedAppInstalled = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Give time for notifications to propagate
    try? await Task.sleep(for: .milliseconds(100))

    // Verify all notifications were triggered
    let activationState = await capture.activationState
    let reachability = await capture.reachability
    let pairedAppInstalled = await capture.pairedAppInstalled

    #expect(activationState == .activated)
    #expect(reachability == true)
    #expect(pairedAppInstalled == true)
  }

  @Test("Update reachability triggers reachability stream")
  internal func updateReachabilityTriggersStream() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    let capture = TestValueCapture()
    let reachabilityId = UUID()

    let reachabilityStream = AsyncStream<Bool> { continuation in
      Task.detached {
        await continuationManager.registerReachability(
          id: reachabilityId,
          continuation: continuation
        )
      }
    }

    Task { @Sendable in
      for await isReachable in reachabilityStream {
        await capture.append(boolValue: isReachable)
        let count = await capture.boolValues.count
        if count >= 2 {
          break
        }
      }
    }

    // Give stream time to register
    try? await Task.sleep(for: .milliseconds(100))

    // Trigger initial activation (should emit false)
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Give time for first notification
    try? await Task.sleep(for: .milliseconds(50))

    // Update reachability (should emit true)
    await stateManager.updateReachability(true)

    // Give time for second notification
    try? await Task.sleep(for: .milliseconds(50))

    let capturedValues = await capture.boolValues
    #expect(capturedValues.count == 2)
    #expect(capturedValues[0] == false)
    #expect(capturedValues[1] == true)
  }

  @Test("Update companion state triggers paired app installed stream")
  internal func updateCompanionStateTriggersStream() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)

    let capture = TestValueCapture()
    let pairedAppInstalledId = UUID()

    let pairedAppInstalledStream = AsyncStream<Bool> { continuation in
      Task.detached {
        await continuationManager.registerPairedAppInstalled(
          id: pairedAppInstalledId,
          continuation: continuation
        )
      }
    }

    Task { @Sendable in
      for await isPairedAppInstalled in pairedAppInstalledStream {
        await capture.set(pairedAppInstalled: isPairedAppInstalled)
        break
      }
    }

    // Give stream time to register
    try? await Task.sleep(for: .milliseconds(100))

    // Update companion state
    await stateManager.updateCompanionState(isPairedAppInstalled: true, isPaired: false)

    // Give time for notification
    try? await Task.sleep(for: .milliseconds(50))

    let capturedValue = await capture.pairedAppInstalled
    #expect(capturedValue == true)
  }
}
