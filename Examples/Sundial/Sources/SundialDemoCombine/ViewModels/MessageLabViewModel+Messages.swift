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
    let components = selectedColor.rgbaComponents

    var message = Sundial_Demo_ColorMessage()
    message.red = Float(components.red)
    message.green = Float(components.green)
    message.blue = Float(components.blue)
    message.alpha = Float(components.alpha)
    message.timestampMs = Date().millisecondsSince1970

    return message
  }

  internal func buildComplexMessage() throws -> Sundial_Demo_ComplexMessage {
    var message = Sundial_Demo_ComplexMessage()
    message.color = buildColorComponent()
    message.deviceInfo = buildDeviceInfo()
    message.colorHistory = buildColorHistory()
    message.sensors = buildSensorData()
    message.messageID = "msg_\(UUID().uuidString.prefix(8))"
    message.createdAtMs = Date().millisecondsSince1970

    return message
  }

  private func buildColorComponent() -> Sundial_Demo_ColorMessage {
    let components = selectedColor.rgbaComponents

    var primaryColor = Sundial_Demo_ColorMessage()
    primaryColor.red = Float(components.red)
    primaryColor.green = Float(components.green)
    primaryColor.blue = Float(components.blue)
    primaryColor.alpha = Float(components.alpha)
    primaryColor.timestampMs = Date().millisecondsSince1970
    return primaryColor
  }

  private func buildDeviceInfo() -> Sundial_Demo_ComplexMessage.DeviceInfo {
    var deviceInfo = Sundial_Demo_ComplexMessage.DeviceInfo()
    #if os(iOS)
      deviceInfo.deviceID = "iOS-Device"
    #elseif os(watchOS)
      deviceInfo.deviceID = "watchOS-Device"
    #else
      deviceInfo.deviceID = "Unknown-Device"
    #endif
    deviceInfo.osVersion = "17.0"
    deviceInfo.appVersion = "1.0.0"
    deviceInfo.locale = Locale.current.identifier
    deviceInfo.bootTimeMs = Date().millisecondsSince1970
    return deviceInfo
  }

  private func buildColorHistory() -> [Sundial_Demo_ColorMessage] {
    (0..<3).map { _ in
      var historyColor = Sundial_Demo_ColorMessage()
      historyColor.red = Float.random(in: 0...1)
      historyColor.green = Float.random(in: 0...1)
      historyColor.blue = Float.random(in: 0...1)
      historyColor.alpha = 1.0
      historyColor.timestampMs = Date().millisecondsSince1970
      return historyColor
    }
  }

  private func buildSensorData() -> [Sundial_Demo_ComplexMessage.SensorData] {
    (0..<5).map { _ in
      var sensor = Sundial_Demo_ComplexMessage.SensorData()
      sensor.temperature = Float.random(in: -10...40)  // Celsius
      sensor.humidity = Float.random(in: 0...100)      // Percentage
      sensor.pressure = Float.random(in: 980...1_050)  // hPa
      sensor.readingTimeMs = Date().millisecondsSince1970
      return sensor
    }
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
