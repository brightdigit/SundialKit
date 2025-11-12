//
//  ConnectivityStateManager.swift
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

public import Foundation
public import SundialKitConnectivity
public import SundialKitCore

/// Manages ConnectivityState and notifies stream subscribers of changes
///
/// This type coordinates state updates with the StreamContinuationManager,
/// ensuring all subscribers receive state change notifications.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public actor ConnectivityStateManager {
  // MARK: - Properties

  private var state: ConnectivityState = .initial
  private let continuationManager: StreamContinuationManager

  // MARK: - State Access

  internal var currentState: ConnectivityState {
    state
  }

  internal var activationState: ActivationState? {
    state.activationState
  }

  internal var activationError: (any Error)? {
    state.activationError
  }

  internal var isReachable: Bool {
    state.isReachable
  }

  internal var isPairedAppInstalled: Bool {
    state.isPairedAppInstalled
  }

  #if os(iOS)
    internal var isPaired: Bool {
      state.isPaired
    }
  #endif

  // MARK: - Initialization

  internal init(continuationManager: StreamContinuationManager) {
    self.continuationManager = continuationManager
  }

  // MARK: - State Updates

  /// Handles activation with full session state snapshot
  internal func handleActivation(
    from session: any ConnectivitySession,
    activationState: ActivationState,
    error: (any Error)?
  ) async {
    // Validate state consistency: activated state should not have an error
    assert(
      !(error != nil && activationState == .activated),
      "Invalid state: activation cannot be .activated with an error present"
    )

    // Capture all session properties at activation time for consistent snapshot
    #if os(iOS)
      state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: session.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: session.isPaired
      )
    #else
      state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: session.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: false  // Always true on watchOS (implicit pairing)
      )
    #endif

    // Notify subscribers
    await continuationManager.yieldActivationState(activationState)

    let result: Result<ActivationState, Error> =
      if let error = error {
        .failure(error)
      } else {
        .success(activationState)
      }
    await continuationManager.yieldActivationCompletion(result)
    await continuationManager.yieldReachability(state.isReachable)
    await continuationManager.yieldPairedAppInstalled(state.isPairedAppInstalled)

    #if os(iOS)
      await continuationManager.yieldPaired(state.isPaired)
    #endif
  }

  /// Legacy method - preserved for backward compatibility
  internal func handleActivation(_ activationState: ActivationState, error: (any Error)?) async {
    // Validate state consistency: activated state should not have an error
    assert(
      !(error != nil && activationState == .activated),
      "Invalid state: activation cannot be .activated with an error present"
    )

    #if os(iOS)
      state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: state.isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: state.isPaired
      )
    #else
      state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: state.isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: false
      )
    #endif

    // Notify subscribers
    await continuationManager.yieldActivationState(activationState)

    let result: Result<ActivationState, Error> =
      if let error = error {
        .failure(error)
      } else {
        .success(activationState)
      }
    await continuationManager.yieldActivationCompletion(result)
    await continuationManager.yieldReachability(state.isReachable)
    await continuationManager.yieldPairedAppInstalled(state.isPairedAppInstalled)

    #if os(iOS)
      await continuationManager.yieldPaired(state.isPaired)
    #endif
  }

  internal func updateReachability(_ isReachable: Bool) async {
    // Verify session has been activated before updating reachability
    assert(
      state.activationState != nil,
      "Cannot update reachability before session activation"
    )

    #if os(iOS)
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: state.isPaired
      )
    #else
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: false
      )
    #endif

    await continuationManager.yieldReachability(isReachable)
  }

  internal func updateCompanionState(isPairedAppInstalled: Bool, isPaired: Bool) async {
    #if os(iOS)
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: state.isReachable,
        isPairedAppInstalled: isPairedAppInstalled,
        isPaired: isPaired
      )
    #else
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: state.isReachable,
        isPairedAppInstalled: isPairedAppInstalled,
        isPaired: true
      )
    #endif

    await continuationManager.yieldPairedAppInstalled(state.isPairedAppInstalled)

    #if os(iOS)
      await continuationManager.yieldPaired(state.isPaired)
    #endif
  }
}
