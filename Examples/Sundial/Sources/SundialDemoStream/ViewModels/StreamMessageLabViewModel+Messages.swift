//
//  StreamMessageLabViewModel+Messages.swift
//  Sundial
//
//  Copyright (c) 2025 BrightDigit.
//

import Foundation
import os.log
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
extension StreamMessageLabViewModel {
  /// RGBA components extracted from a received message.
  private struct ColorComponents {
    fileprivate let red: Double
    fileprivate let green: Double
    fileprivate let blue: Double
    fileprivate let alpha: Double
  }

  // MARK: - Static Helpers

  private static func colorComponents(from message: any Messagable) -> ColorComponents? {
    if let colorMessage = message as? Sundial_Demo_ColorMessage {
      return ColorComponents(
        red: Double(colorMessage.red),
        green: Double(colorMessage.green),
        blue: Double(colorMessage.blue),
        alpha: Double(colorMessage.alpha)
      )
    }
    if let complexMessage = message as? Sundial_Demo_ComplexMessage {
      let color = complexMessage.color
      return ColorComponents(
        red: Double(color.red),
        green: Double(color.green),
        blue: Double(color.blue),
        alpha: Double(color.alpha)
      )
    }
    return nil
  }

  // MARK: - Instance Methods

  internal func buildMessage() throws -> any BinaryMessagable {
    if complexityLevel < 0.5 {
      return try buildColorMessage()
    } else {
      return try buildComplexMessage()
    }
  }

  internal func handleReceivedTypedMessage(_ message: any Messagable) {
    logIfAvailable {
      DemoLogger.shared.debug(
        "Received typed message: \(String(describing: type(of: message)))"
      )
    }

    guard let components = Self.colorComponents(from: message) else {
      logIfAvailable {
        DemoLogger.shared.debug(
          "Unknown message type: \(String(describing: type(of: message)))"
        )
      }
      return
    }

    lastReceivedColor = ColorWithMetadata(
      color: Color(
        red: components.red,
        green: components.green,
        blue: components.blue,
        opacity: components.alpha
      ),
      timestamp: Date(),
      source: "Counterpart Device"
    )
    messagesReceived += 1
    logIfAvailable {
      DemoLogger.shared.debug("Updated received color: \(String(describing: components))")
    }
  }

  private func buildColorMessage() throws -> Sundial_Demo_ColorMessage {
    Sundial_Demo_ColorMessage.make(from: selectedColor)
  }

  private func buildComplexMessage() throws -> Sundial_Demo_ComplexMessage {
    Sundial_Demo_ComplexMessage.make(color: selectedColor)
  }
}
