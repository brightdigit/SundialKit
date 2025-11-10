//
//  StateHandling.swift
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

internal import Foundation
internal import SundialKitConnectivity
//
//  StateHandling.swift
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
internal import SundialKitCore

/// Protocol for types that handle connectivity state changes
///
/// Provides default implementations for common state handling patterns
/// by delegating to a `ConnectivityStateManager`.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol StateHandling {
  /// The state manager responsible for tracking connectivity state
  var stateManager: ConnectivityStateManager { get }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension StateHandling {
  /// Handles activation with full session state snapshot
  /// - Parameters:
  ///   - session: The connectivity session with current state
  ///   - activationState: The new activation state
  ///   - error: Optional error that occurred during activation
  internal func handleActivation(
    from session: any ConnectivitySession,
    activationState: ActivationState,
    error: Error?
  ) async {
    await stateManager.handleActivation(from: session, activationState: activationState, error: error)
  }

  /// Handles activation state changes and errors (legacy)
  /// - Parameters:
  ///   - activationState: The new activation state
  ///   - error: Optional error that occurred during activation
  internal func handleActivation(_ activationState: ActivationState, error: Error?) async {
    await stateManager.handleActivation(activationState, error: error)
  }

  /// Handles reachability status changes
  /// - Parameter isReachable: Whether the counterpart device is reachable
  internal func handleReachabilityChange(_ isReachable: Bool) async {
    await stateManager.updateReachability(isReachable)
  }

  /// Handles companion state changes (paired status, app installed status)
  /// - Parameter session: The connectivity session with updated state
  internal func handleCompanionStateChange(_ session: any ConnectivitySession) async {
    await stateManager.updateCompanionState(
      isPairedAppInstalled: session.isPairedAppInstalled,
      isPaired: session.isPaired
    )
  }
}
