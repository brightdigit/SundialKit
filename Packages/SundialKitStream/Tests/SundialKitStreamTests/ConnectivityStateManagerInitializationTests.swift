//
//  ConnectivityStateManagerInitializationTests.swift
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

@Suite("ConnectivityStateManager Initialization and Activation Tests")
internal struct ConnectivityStateManagerInitializationTests {
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
}
