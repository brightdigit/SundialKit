//
//  ConnectivityState.swift
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

import SundialKitCore

/// Immutable value type representing WatchConnectivity session state.
///
/// `ConnectivityState` encapsulates the current state of a connectivity session,
/// including activation status, reachability, and pairing information. This value
/// type is used internally by `ConnectivityObserver` for state management.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
internal struct ConnectivityState: Sendable {
  /// The current activation state of the session.
  internal let activationState: ActivationState?

  /// The last error that occurred during activation, if any.
  internal let activationError: (any Error & Sendable)?

  /// Whether the counterpart device is currently reachable.
  internal let isReachable: Bool

  /// Whether the counterpart app is installed on the paired device.
  internal let isPairedAppInstalled: Bool

  /// Whether an Apple Watch is paired with this iPhone (iOS only).
  internal let isPaired: Bool

  /// The default initial state before activation.
  internal static let initial = ConnectivityState(
    activationState: nil,
    activationError: nil,
    isReachable: false,
    isPairedAppInstalled: false,
    isPaired: false
  )
}
