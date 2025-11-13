//
//  ConnectivityStateManagerStateTests.swift
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

@Suite("ConnectivityStateManager State Update and Property Tests")
internal struct ConnectivityStateManagerStateTests {
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
}
