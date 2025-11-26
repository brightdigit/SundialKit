//
// ActivationState.swift
// Copyright (c) 2025 BrightDigit.
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
/// > Important: Attempting to send messages in
/// ``notActivated`` or ``inactive`` states is a programmer error.
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
