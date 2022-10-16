/// Identical to `WCSessionActivationState`, these are constants indicating the activation state of a session.
public enum ActivationState: Int {
  /// The session is not activated. When in this state, no communication occurs between the Watch app and iOS app. It is a programmer error to try to send data to the counterpart app while in this state.
  case notActivated = 0
  /// The session was active but is transitioning to the deactivated state. The session’s delegate object may still receive data while in this state, but it is a programmer error to try to send data to the counterpart app.
  case inactive = 1
  /// The session is active and the Watch app and iOS app may communicate with each other freely.
  case activated = 2
}
