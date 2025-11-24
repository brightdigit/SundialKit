//
//  ColorMessageExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance and SwiftUI helpers for ColorMessage.
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - BinaryMessagable Conformance

extension Sundial_Demo_ColorMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedBytes: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

// MARK: - Convenience Extensions for SwiftUI

#if canImport(SwiftUI)
  extension Sundial_Demo_ColorMessage {
    /// Convert to SwiftUI Color
    public var color: Color {
      Color(
        red: Double(red),
        green: Double(green),
        blue: Double(blue),
        opacity: Double(alpha)
      )
    }

    /// Create from SwiftUI Color and timestamp
    public init(color: Color, timestamp: Date = Date(), source: String = "") {
      self.init()
      let components = color.components
      self.red = Float(components.red)
      self.green = Float(components.green)
      self.blue = Float(components.blue)
      self.alpha = Float(components.alpha)
      self.timestampMs = timestamp.timeIntervalSince1970Milliseconds
      self.source = source
    }

    /// Timestamp as Date
    public var timestamp: Date {
      Date(millisecondsSince1970: timestampMs)
    }
  }
#endif
