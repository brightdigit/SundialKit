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

  internal var state: ConnectivityState = .initial
  internal let continuationManager: StreamContinuationManager

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
}
