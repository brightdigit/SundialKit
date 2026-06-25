//
//  ColorSnapshot.swift
//  Sundial
//
//  A revisioned color snapshot synced via SundialKitStreamContext's ContextEngine.
//
//  Copyright (c) 2026 BrightDigit.
//

#if os(iOS) || os(watchOS)
  import Foundation
  import SundialKitConnectivity
  import SundialKitCore
  import SundialKitStreamContext

  /// The whole "current color" a device wants its counterpart to display.
  ///
  /// Conforms to ``RevisionedMessage`` so each send carries a monotonically
  /// increasing ``revision`` — that keeps every application-context write a
  /// distinct payload, so a heartbeat re-assert or reconnect re-sync is never
  /// silently deduped in transit.
  internal struct ColorSnapshot: RevisionedMessage {
    private enum Key: String {
      case red, green, blue, alpha, revision
    }

    internal let red: Double
    internal let green: Double
    internal let blue: Double
    internal let alpha: Double
    internal let revision: UInt64

    internal init(red: Double, green: Double, blue: Double, alpha: Double, revision: UInt64) {
      self.red = red
      self.green = green
      self.blue = blue
      self.alpha = alpha
      self.revision = revision
    }

    internal init(from parameters: [String: any Sendable]) throws {
      guard let red = parameters[Key.red.rawValue] as? Double else {
        throw SerializationError.missingField(Key.red.rawValue)
      }
      guard let green = parameters[Key.green.rawValue] as? Double else {
        throw SerializationError.missingField(Key.green.rawValue)
      }
      guard let blue = parameters[Key.blue.rawValue] as? Double else {
        throw SerializationError.missingField(Key.blue.rawValue)
      }
      guard let alpha = parameters[Key.alpha.rawValue] as? Double else {
        throw SerializationError.missingField(Key.alpha.rawValue)
      }

      self.init(
        red: red,
        green: green,
        blue: blue,
        alpha: alpha,
        revision: Self.revision(from: parameters[Key.revision.rawValue])
      )
    }

    /// Tolerant decode of the revision, which can come back from the transport as
    /// any numeric flavor depending on property-list bridging.
    private static func revision(from value: (any Sendable)?) -> UInt64 {
      if let revision = value as? UInt64 {
        return revision
      }
      if let int = value as? Int, int >= 0 {
        return UInt64(int)
      }
      if let double = value as? Double, double >= 0, double <= Double(UInt64.max) {
        return UInt64(double)
      }
      return 0
    }

    internal func parameters() -> [String: any Sendable] {
      [
        Key.red.rawValue: red,
        Key.green.rawValue: green,
        Key.blue.rawValue: blue,
        Key.alpha.rawValue: alpha,
        Key.revision.rawValue: revision,
      ]
    }
  }
#endif
