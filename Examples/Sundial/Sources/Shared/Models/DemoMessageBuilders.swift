//
//  DemoMessageBuilders.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2026 BrightDigit.
//
//  Shared payload builders so the Combine and Stream Message Lab variants
//  construct identical color/complex messages from a single source of truth.
//

import Foundation

#if canImport(SwiftUI)
  import SwiftUI
#endif

#if canImport(WatchKit)
  import WatchKit
#endif

#if canImport(UIKit)
  import UIKit
#endif

// MARK: - Device Info

extension Sundial_Demo_ComplexMessage.DeviceInfo {
  /// Build device info for the current device, reporting the *real* OS version
  /// rather than a hardcoded placeholder.
  public static func current() -> Sundial_Demo_ComplexMessage.DeviceInfo {
    var deviceInfo = Sundial_Demo_ComplexMessage.DeviceInfo()
    #if os(watchOS)
      deviceInfo.deviceID = "watchOS-Device"
      deviceInfo.osVersion = WKInterfaceDevice.current().systemVersion
    #elseif os(iOS)
      deviceInfo.deviceID = "iOS-Device"
      deviceInfo.osVersion = UIDevice.current.systemVersion
    #elseif os(macOS)
      deviceInfo.deviceID = "macOS-Device"
      deviceInfo.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    #else
      deviceInfo.deviceID = "Unknown-Device"
      deviceInfo.osVersion = ""
    #endif
    deviceInfo.appVersion = "1.0.0"
    deviceInfo.locale = Locale.current.identifier
    deviceInfo.bootTimeMs = Date.nowMilliseconds
    return deviceInfo
  }
}

// MARK: - Random Sample Data

extension Sundial_Demo_ComplexMessage {
  /// Generate a random color history for the complex payload.
  public static func randomColorHistory(count: Int = 3) -> [Sundial_Demo_ColorMessage] {
    (0..<count).map { _ in
      var historyColor = Sundial_Demo_ColorMessage()
      historyColor.red = Float.random(in: 0...1)
      historyColor.green = Float.random(in: 0...1)
      historyColor.blue = Float.random(in: 0...1)
      historyColor.alpha = 1.0
      historyColor.timestampMs = Date.nowMilliseconds
      return historyColor
    }
  }

  /// Generate random sensor readings for the complex payload.
  public static func randomSensors(count: Int = 5) -> [Sundial_Demo_ComplexMessage.SensorData] {
    (0..<count).map { _ in
      var sensor = Sundial_Demo_ComplexMessage.SensorData()
      sensor.temperature = Float.random(in: -10...40)  // Celsius
      sensor.humidity = Float.random(in: 0...100)  // Percentage
      sensor.pressure = Float.random(in: 980...1_050)  // hPa
      sensor.readingTimeMs = Date.nowMilliseconds
      return sensor
    }
  }
}

// MARK: - Color-driven Builders

#if canImport(SwiftUI)
  extension Sundial_Demo_ColorMessage {
    /// Build a color message from a SwiftUI `Color`.
    public static func make(from color: Color) -> Sundial_Demo_ColorMessage {
      Sundial_Demo_ColorMessage(color: color)
    }
  }

  extension Sundial_Demo_ComplexMessage {
    /// Build a complete complex message from a SwiftUI `Color`, populating the
    /// primary color, device info, random color history, and random sensors.
    public static func make(color: Color) -> Sundial_Demo_ComplexMessage {
      var message = Sundial_Demo_ComplexMessage()
      message.color = Sundial_Demo_ColorMessage(color: color)
      message.deviceInfo = Sundial_Demo_ComplexMessage.DeviceInfo.current()
      message.colorHistory = randomColorHistory()
      message.sensors = randomSensors()
      message.messageID = "msg_\(UUID().uuidString.prefix(8))"
      message.createdAtMs = Date.nowMilliseconds
      return message
    }
  }
#endif
