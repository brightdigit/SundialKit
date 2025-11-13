//
//  ConnectivityStateManagerTests.swift
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

// MARK: - Mock Session

internal final class MockConnectivitySession: ConnectivitySession, @unchecked Sendable {
  var delegate: (any ConnectivitySessionDelegate)?
  var isReachable: Bool = false
  var isPairedAppInstalled: Bool = false
  var isPaired: Bool = false
  var activationState: ActivationState = .notActivated
  var receivedApplicationContext: ConnectivityMessage?

  func activate() throws {}

  func updateApplicationContext(_ context: ConnectivityMessage) throws {}

  func sendMessage(
    _ message: ConnectivityMessage,
    _ replyHandler: @escaping (Result<ConnectivityMessage, any Error>) -> Void
  ) {}

  func sendMessageData(
    _ data: Data,
    _ completion: @escaping (Result<Data, any Error>) -> Void
  ) {}
}

// MARK: - Test Suite

@Suite("ConnectivityStateManager Tests")
internal struct ConnectivityStateManagerTests {
  // MARK: - Initialization Tests

  @Test("Initial state is correct")
  internal func initialState() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)

    let state = await stateManager.currentState

    #expect(state.activationState == nil)
    #expect(state.activationError == nil)
    #expect(state.isReachable == false)
    #expect(state.isPairedAppInstalled == false)
    #expect(state.isPaired == false)
  }

  @Test("ConnectivityState.initial constant has expected values")
  internal func connectivityStateInitial() {
    let initial = ConnectivityState.initial

    #expect(initial.activationState == nil)
    #expect(initial.activationError == nil)
    #expect(initial.isReachable == false)
    #expect(initial.isPairedAppInstalled == false)
    #expect(initial.isPaired == false)
  }

  // MARK: - Activation Handling Tests

  @Test("Handle activation with .activated state captures session snapshot")
  internal func handleActivationActivated() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up session state
    session.activationState = .activated
    session.isReachable = true
    session.isPairedAppInstalled = true
    session.isPaired = true

    await stateManager.handleActivation(
      from: session,
      activationState: .activated,
      error: nil
    )

    let state = await stateManager.currentState

    #expect(state.activationState == .activated)
    #expect(state.activationError == nil)
    #expect(state.isReachable == true)
    #expect(state.isPairedAppInstalled == true)
    #if os(iOS)
      #expect(state.isPaired == true)
    #else
      // watchOS always reports isPaired as false internally
      #expect(state.isPaired == false)
    #endif
  }

  @Test("Handle activation with .inactive state")
  internal func handleActivationInactive() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    session.activationState = .inactive

    await stateManager.handleActivation(
      from: session,
      activationState: .inactive,
      error: nil
    )

    let activationState = await stateManager.activationState
    #expect(activationState == .inactive)
  }

  @Test("Handle activation with .notActivated state")
  internal func handleActivationNotActivated() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    session.activationState = .notActivated

    await stateManager.handleActivation(
      from: session,
      activationState: .notActivated,
      error: nil
    )

    let activationState = await stateManager.activationState
    #expect(activationState == .notActivated)
  }

  @Test("Handle activation with error stores error")
  internal func handleActivationWithError() async {
    struct TestError: Error, Sendable {}

    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    session.activationState = .inactive

    await stateManager.handleActivation(
      from: session,
      activationState: .inactive,
      error: TestError()
    )

    let activationError = await stateManager.activationError
    #expect(activationError != nil)
    #expect(activationError is TestError)
  }

  // MARK: - Legacy Activation Method Tests

  @Test("Legacy handleActivation preserves existing state")
  internal func legacyHandleActivation() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // First set up state with reachability
    session.isReachable = true
    session.isPairedAppInstalled = true
    session.isPaired = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Now use legacy method to change only activation state
    await stateManager.handleActivation(.inactive, error: nil)

    let state = await stateManager.currentState

    #expect(state.activationState == .inactive)
    // These should be preserved from first call
    #expect(state.isReachable == true)
    #expect(state.isPairedAppInstalled == true)
    #if os(iOS)
      #expect(state.isPaired == true)
    #endif
  }

  // MARK: - Reachability Update Tests

  @Test("Update reachability changes state")
  internal func updateReachability() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Activate first
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Update reachability
    await stateManager.updateReachability(true)

    let isReachable = await stateManager.isReachable
    #expect(isReachable == true)
  }

  @Test("Update reachability preserves other state")
  internal func updateReachabilityPreservesState() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up initial state
    session.activationState = .activated
    session.isPairedAppInstalled = true
    session.isPaired = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Update reachability
    await stateManager.updateReachability(true)

    let state = await stateManager.currentState

    #expect(state.activationState == .activated)
    #expect(state.isPairedAppInstalled == true)
    #if os(iOS)
      #expect(state.isPaired == true)
    #endif
  }

  // MARK: - Companion State Update Tests

  @Test("Update companion state changes both values on iOS")
  internal func updateCompanionState() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)

    await stateManager.updateCompanionState(isPairedAppInstalled: true, isPaired: true)

    let state = await stateManager.currentState

    #expect(state.isPairedAppInstalled == true)
    #if os(iOS)
      #expect(state.isPaired == true)
    #else
      // watchOS always true (implicit pairing)
      #expect(state.isPaired == true)
    #endif
  }

  @Test("Update companion state preserves activation state")
  internal func updateCompanionStatePreservesActivation() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up initial state
    session.activationState = .activated
    session.isReachable = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    // Update companion state
    await stateManager.updateCompanionState(isPairedAppInstalled: true, isPaired: true)

    let state = await stateManager.currentState

    #expect(state.activationState == .activated)
    #expect(state.isReachable == true)
  }

  // MARK: - State Property Accessor Tests

  @Test("activationState getter returns correct value")
  internal func activationStateGetter() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    let activationState = await stateManager.activationState
    #expect(activationState == .activated)
  }

  @Test("activationError getter returns correct value")
  internal func activationErrorGetter() async {
    struct TestError: Error, Sendable {}

    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    await stateManager.handleActivation(
      from: session,
      activationState: .inactive,
      error: TestError()
    )

    let activationError = await stateManager.activationError
    #expect(activationError is TestError)
  }

  @Test("isReachable getter returns correct value")
  internal func isReachableGetter() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    session.isReachable = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    let isReachable = await stateManager.isReachable
    #expect(isReachable == true)
  }

  @Test("isPairedAppInstalled getter returns correct value")
  internal func isPairedAppInstalledGetter() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    session.isPairedAppInstalled = true
    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    let isPairedAppInstalled = await stateManager.isPairedAppInstalled
    #expect(isPairedAppInstalled == true)
  }

  #if os(iOS)
    @Test("isPaired getter returns correct value on iOS")
    internal func isPairedGetter() async {
      let continuationManager = StreamContinuationManager()
      let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
      let session = MockConnectivitySession()

      session.isPaired = true
      await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

      let isPaired = await stateManager.isPaired
      #expect(isPaired == true)
    }
  #endif

  // MARK: - State Consistency Tests

  @Test("State snapshot is consistent across all properties")
  internal func stateSnapshotConsistency() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up complete session state
    session.activationState = .activated
    session.isReachable = true
    session.isPairedAppInstalled = true
    session.isPaired = true

    await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

    let state = await stateManager.currentState

    // All properties should match session state
    #expect(state.activationState == .activated)
    #expect(state.activationError == nil)
    #expect(state.isReachable == true)
    #expect(state.isPairedAppInstalled == true)
    #if os(iOS)
      #expect(state.isPaired == true)
    #else
      #expect(state.isPaired == false)
    #endif
  }

  // MARK: - Stream Notification Integration Tests
  // Note: These tests verify that state changes trigger notifications via continuationManager

  @Test("Handle activation triggers all stream notifications")
  internal func handleActivationTriggersNotifications() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    // Set up state capture
    var capturedActivationState: ActivationState?
    var capturedReachability: Bool?
    var capturedPairedAppInstalled: Bool?

    // Create streams with proper Task wrapping
    let activationId = UUID()
    let reachabilityId = UUID()
    let pairedAppInstalledId = UUID()

    let activationStream = AsyncStream<ActivationState> { continuation in
      Task {
        await continuationManager.registerActivation(id: activationId, continuation: continuation)
      }
    }

    let reachabilityStream = AsyncStream<Bool> { continuation in
      Task {
        await continuationManager.registerReachability(
          id: reachabilityId, continuation: continuation)
      }
    }

    let pairedAppInstalledStream = AsyncStream<Bool> { continuation in
      Task {
        await continuationManager.registerPairedAppInstalled(
          id: pairedAppInstalledId,
          continuation: continuation
        )
      }
    }

    // Consume streams
    Task {
      for await state in activationStream {
        capturedActivationState = state
        break
      }
    }

    Task {
      for await isReachable in reachabilityStream {
        capturedReachability = isReachable
        break
      }
    }

    Task {
      for await isPairedAppInstalled in pairedAppInstalledStream {
        capturedPairedAppInstalled = isPairedAppInstalled
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
    #expect(capturedActivationState == .activated)
    #expect(capturedReachability == true)
    #expect(capturedPairedAppInstalled == true)
  }

  @Test("Update reachability triggers reachability stream")
  internal func updateReachabilityTriggersStream() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    let session = MockConnectivitySession()

    var capturedValues: [Bool] = []
    let reachabilityId = UUID()

    let reachabilityStream = AsyncStream<Bool> { continuation in
      Task {
        await continuationManager.registerReachability(
          id: reachabilityId, continuation: continuation)
      }
    }

    Task {
      for await isReachable in reachabilityStream {
        capturedValues.append(isReachable)
        if capturedValues.count >= 2 {
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

    #expect(capturedValues.count == 2)
    #expect(capturedValues[0] == false)
    #expect(capturedValues[1] == true)
  }

  @Test("Update companion state triggers paired app installed stream")
  internal func updateCompanionStateTriggersStream() async {
    let continuationManager = StreamContinuationManager()
    let stateManager = ConnectivityStateManager(continuationManager: continuationManager)

    var capturedValue: Bool?
    let pairedAppInstalledId = UUID()

    let pairedAppInstalledStream = AsyncStream<Bool> { continuation in
      Task {
        await continuationManager.registerPairedAppInstalled(
          id: pairedAppInstalledId,
          continuation: continuation
        )
      }
    }

    Task {
      for await isPairedAppInstalled in pairedAppInstalledStream {
        capturedValue = isPairedAppInstalled
        break
      }
    }

    // Give stream time to register
    try? await Task.sleep(for: .milliseconds(100))

    // Update companion state
    await stateManager.updateCompanionState(isPairedAppInstalled: true, isPaired: false)

    // Give time for notification
    try? await Task.sleep(for: .milliseconds(50))

    #expect(capturedValue == true)
  }
}
