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

  private static func makeDeviceInfo() -> Sundial_Demo_ComplexMessage.DeviceInfo {
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

  private static func makeColorHistory() -> [Sundial_Demo_ColorMessage] {
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

  private static func makeSensors() -> [Sundial_Demo_ComplexMessage.SensorData] {
    (0..<5).map { _ in
      var sensor = Sundial_Demo_ComplexMessage.SensorData()
      sensor.temperature = Float.random(in: -10...40)  // Celsius
      sensor.humidity = Float.random(in: 0...100)  // Percentage
      sensor.pressure = Float.random(in: 980...1_050)  // hPa
      sensor.readingTimeMs = Date().millisecondsSince1970
      return sensor
    }
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
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      DemoLogger.shared.debug(
        "Received typed message: \(String(describing: type(of: message)))"
      )
    }

    guard let components = Self.colorComponents(from: message) else {
      if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
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
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      DemoLogger.shared.debug("Updated received color: \(String(describing: components))")
    }
  }

  private func buildColorMessage() throws -> Sundial_Demo_ColorMessage {
    let components = selectedColor.rgbaComponents

    var message = Sundial_Demo_ColorMessage()
    message.red = Float(components.red)
    message.green = Float(components.green)
    message.blue = Float(components.blue)
    message.alpha = Float(components.alpha)
    message.timestampMs = Date().millisecondsSince1970

    return message
  }

  private func buildComplexMessage() throws -> Sundial_Demo_ComplexMessage {
    let components = selectedColor.rgbaComponents

    var message = Sundial_Demo_ComplexMessage()

    var primaryColor = Sundial_Demo_ColorMessage()
    primaryColor.red = Float(components.red)
    primaryColor.green = Float(components.green)
    primaryColor.blue = Float(components.blue)
    primaryColor.alpha = Float(components.alpha)
    primaryColor.timestampMs = Date().millisecondsSince1970
    message.color = primaryColor

    message.deviceInfo = Self.makeDeviceInfo()
    message.colorHistory = Self.makeColorHistory()
    message.sensors = Self.makeSensors()
    message.messageID = "msg_\(UUID().uuidString.prefix(8))"
    message.createdAtMs = Date().millisecondsSince1970

    return message
  }
}
