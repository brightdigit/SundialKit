import Foundation

/// Specific errors thrown by framework.
public enum SundialError: Error {
  /// If WCSession.isSupport is true,
  /// you will throw this error at ``ConnectivityObserver/activate()``.
  case sessionNotSupported
  /// When there is no companion device (i.e. iPhone or Apple Watch)
  case missingCompanion
}
