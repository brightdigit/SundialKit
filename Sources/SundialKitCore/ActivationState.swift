//
//  ActivationState.swift
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

/// Constants indicating the activation state of a WatchConnectivity session.
///
/// These states correspond to `WCSessionActivationState` and represent the lifecycle
/// of a connectivity session between an iPhone and Apple Watch.
///
/// ## State Transitions
///
/// The typical state flow:
/// 1. Session starts in ``notActivated``
/// 2. After calling activate, transitions to ``activated``
/// 3. On deactivation, transitions through ``inactive`` before returning to ``notActivated``
///
/// ## Example
///
/// ```swift
/// switch activationState {
/// case .notActivated:
///   print("Session not yet activated - call activate()")
/// case .inactive:
///   print("Session deactivating - can receive but cannot send")
/// case .activated:
///   print("Session active - can send and receive messages")
/// }
/// ```
///
/// > Important: Attempting to send messages in ``notActivated`` or ``inactive`` states is a programmer error.
public enum ActivationState: Int, Sendable {
  /// The session is not activated.
  ///
  /// When in this state, no communication occurs between the Watch app and iOS app.
  /// It is a programmer error to try to send data to the counterpart app while in this state.
  case notActivated = 0

  /// The session was active but is transitioning to the deactivated state.
  ///
  /// The session's delegate object may still receive data while in this state,
  /// but it is a programmer error to try to send data to the counterpart app.
  case inactive = 1

  /// The session is active.
  ///
  /// The Watch app and iOS app may communicate with each other freely.
  case activated = 2
}
