import Foundation

/// Represents an error entry in the diagnostics error log.
public struct ErrorEntry: Identifiable, Sendable {
  public let id = UUID()
  public let timestamp: Date
  public let description: String
  public let severity: Severity

  public init(
    timestamp: Date = Date(),
    description: String,
    severity: Severity = .error
  ) {
    self.timestamp = timestamp
    self.description = description
    self.severity = severity
  }

  /// Error severity levels for diagnostics display.
  public enum Severity: String, Sendable {
    case info
    case warning
    case error
  }
}
