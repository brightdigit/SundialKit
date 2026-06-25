//
//  MessageLabViewModel+Messages.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
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

import Foundation
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
extension MessageLabViewModel {
  /// Color channel components extracted from a received message.
  internal struct ColorComponents {
    internal let red: Double
    internal let green: Double
    internal let blue: Double
    internal let alpha: Double
  }

  // MARK: - Actions

  /// Generate a random color.
  internal func randomizeColor() {
    selectedColor = Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }

  // MARK: - Message Building

  internal func buildMessage() throws -> any BinaryMessagable {
    if complexityLevel < 0.5 {
      return try buildColorMessage()
    } else {
      return try buildComplexMessage()
    }
  }

  internal func buildColorMessage() throws -> Sundial_Demo_ColorMessage {
    Sundial_Demo_ColorMessage.make(from: selectedColor)
  }

  internal func buildComplexMessage() throws -> Sundial_Demo_ComplexMessage {
    Sundial_Demo_ComplexMessage.make(color: selectedColor)
  }

  // MARK: - Send Result Handling

  internal func handleSendSuccess(context: ConnectivitySendContext) {
    logInfo("Message sent successfully via: \(String(describing: context))")
    lastSentColor = ColorWithMetadata(
      color: selectedColor,
      timestamp: Date(),
      source: "This Device"
    )
    messagesSent += 1
    logDebug("UI state updated - messagesSent: \(self.messagesSent)")
  }

  internal func handleSendFailure(_ error: any Error) {
    lastError = error.localizedDescription
    logError("Send error: \(error)")
    logError("Error description: \(error.localizedDescription)")
  }

  // MARK: - Message Handling

  internal func handleReceivedTypedMessage(_ message: any Messagable) {
    logDebug("Received typed message: \(type(of: message))")

    guard let components = colorComponents(from: message) else {
      logDebug("Unknown message type: \(type(of: message))")
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
    logDebug("Updated received color: \(String(describing: components))")
  }

  private func colorComponents(from message: any Messagable) -> ColorComponents? {
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
}
