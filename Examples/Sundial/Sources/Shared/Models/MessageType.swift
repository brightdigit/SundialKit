import Foundation

/// Message types for protocol comparison testing.
public enum MessageType: String, Sendable, CaseIterable, Identifiable {
  case simple = "Simple Color"
  case complex = "Complex Nested"

  public var id: String { rawValue }

  /// Human-readable description of the message type.
  public var description: String {
    switch self {
    case .simple:
      "ColorMessage with RGB components"
    case .complex:
      "ComplexMessage with nested structures"
    }
  }
}
