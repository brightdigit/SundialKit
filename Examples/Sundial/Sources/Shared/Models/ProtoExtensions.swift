//
//  ProtoExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance for SwiftProtobuf generated types.
//  Direct conformance without wrappers - SwiftProtobuf already has the right methods!
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

#if canImport(SwiftUI)
  import SwiftUI
#endif

// MARK: - BinaryMessagable Conformance

// SwiftProtobuf generates types with:
// - init(serializedData: Data) throws
// - func serializedData() throws -> Data
//
// BinaryMessagable requires:
// - init(from data: Data) throws
// - func encode() throws -> Data
//
// These signatures align perfectly, so we just need thin adapters.

extension Sundial_Demo_ColorMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

extension Sundial_Demo_ComplexMessage: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

extension Sundial_Demo_LatencyTestRequest: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

extension Sundial_Demo_LatencyTestReply: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}

extension Sundial_Demo_LatencyStats: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
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

// MARK: - LatencyTestRequest Helpers

extension Sundial_Demo_LatencyTestRequest {
  /// Create a latency test request
  public static func create(
    sequenceNumber: Int64,
    payloadSize: PayloadSize = .small
  ) -> Sundial_Demo_LatencyTestRequest {
    var request = Sundial_Demo_LatencyTestRequest()
    request.sendTimestampMs = Date.nowMilliseconds
    request.sequenceNumber = sequenceNumber
    request.payloadSize = payloadSize

    // Generate payload based on size category
    let size: Int
    switch payloadSize {
    case .small:
      size = 50
    case .medium:
      size = 500
    case .large:
      size = 5000
    case .UNRECOGNIZED:
      size = 50
    }

    request.payload = Data(count: size)

    return request
  }
}

// MARK: - LatencyTestReply Helpers

extension Sundial_Demo_LatencyTestReply {
  /// Create a reply from a request
  public static func create(
    from request: Sundial_Demo_LatencyTestRequest,
    receiveTime: Date,
    processingTimeUs: Int64 = 0
  ) -> Sundial_Demo_LatencyTestReply {
    var reply = Sundial_Demo_LatencyTestReply()
    reply.receiveTimestampMs = receiveTime.timeIntervalSince1970Milliseconds
    reply.replyTimestampMs = Date.nowMilliseconds
    reply.sequenceNumber = request.sequenceNumber
    reply.processingTimeUs = processingTimeUs
    reply.payload = request.payload  // Echo back

    return reply
  }

  /// Calculate round-trip time from the original request
  public func roundTripTime(from request: Sundial_Demo_LatencyTestRequest) -> TimeInterval {
    let sendTime = Date(millisecondsSince1970: request.sendTimestampMs)
    let replyTime = Date(millisecondsSince1970: replyTimestampMs)
    return replyTime.timeIntervalSince(sendTime)
  }
}
