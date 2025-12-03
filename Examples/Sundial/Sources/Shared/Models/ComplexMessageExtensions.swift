//
//  ComplexMessageExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance and helpers for ComplexMessage.
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

#if canImport(SwiftUI)
  import SwiftUI
#endif

#if canImport(WatchKit)
  import WatchKit
#endif

#if canImport(UIKit)
  import UIKit
#endif

// MARK: - BinaryMessagable Conformance

extension Sundial_Demo_ComplexMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

// MARK: - ComplexMessage Helpers

extension Sundial_Demo_ComplexMessage {
  /// Create a sample complex message for testing
  public static func sample() -> Sundial_Demo_ComplexMessage {
    var msg = Sundial_Demo_ComplexMessage()

    #if canImport(SwiftUI)
      msg.color = Sundial_Demo_ColorMessage(color: .blue, source: "Sample")
    #endif

    // Add sample sensor data
    var sensor1 = Sundial_Demo_ComplexMessage.SensorData()
    sensor1.temperature = 22.5
    sensor1.humidity = 45.0
    sensor1.pressure = 1013.25
    sensor1.readingTimeMs = Date.nowMilliseconds
    msg.sensors = [sensor1]

    // Add device info
    var deviceInfo = Sundial_Demo_ComplexMessage.DeviceInfo()
    #if os(watchOS)

      deviceInfo.deviceID =
        WKInterfaceDevice.current().identifierForVendor?.uuidString ?? "unknown"
    deviceInfo.osVersion = WKInterfaceDevice.current().systemVersion
    #elseif os(iOS)
    deviceInfo.deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
      deviceInfo.osVersion = UIDevice.current.systemVersion
    #elseif os(macOS)
      deviceInfo.deviceID = "mac-device"
      deviceInfo.osVersion = ProcessInfo.processInfo.operatingSystemVersionString
    #endif
    deviceInfo.appVersion =
      Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    deviceInfo.bootTimeMs = Date.nowMilliseconds
    msg.deviceInfo = deviceInfo

    msg.createdAtMs = Date.nowMilliseconds
    msg.messageID = UUID().uuidString

    return msg
  }

  /// Estimated size in bytes (before encoding)
  public var estimatedSize: Int {
    (try? serializedData().count) ?? 0
  }
}
