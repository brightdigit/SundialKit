import Foundation

/// Represents a single message transmission entry in the diagnostics history.
public struct MessageHistoryEntry: Identifiable, Sendable {
  public let id = UUID()
  public let timestamp: Date
  public let method: TransportMethod
  public let size: Int
  public let rtt: TimeInterval?
  public let success: Bool

  public init(
    timestamp: Date = Date(),
    method: TransportMethod,
    size: Int,
    rtt: TimeInterval? = nil,
    success: Bool
  ) {
    self.timestamp = timestamp
    self.method = method
    self.size = size
    self.rtt = rtt
    self.success = success
  }
}
