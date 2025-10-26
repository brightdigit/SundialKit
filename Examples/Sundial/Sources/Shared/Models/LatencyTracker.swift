//
//  LatencyTracker.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation

/// Tracks latency measurements for message transmission
@MainActor
public final class LatencyTracker: ObservableObject {
  /// Individual latency measurement
  public struct Measurement: Identifiable, Sendable {
    public let id = UUID()
    public let sequenceNumber: Int
    public let sendTime: Date
    public let receiveTime: Date
    public let transportMethod: TransportMethod
    public let payloadSize: Int
    public let encodeTime: TimeInterval
    public let decodeTime: TimeInterval

    /// Total round-trip time
    public var roundTripTime: TimeInterval {
      receiveTime.timeIntervalSince(sendTime)
    }

    /// Estimated network transmission time
    public var networkTime: TimeInterval {
      roundTripTime - encodeTime - decodeTime
    }

    /// Round-trip time in milliseconds
    public var rttMilliseconds: Double {
      roundTripTime * 1000
    }

    public init(
      sequenceNumber: Int,
      sendTime: Date,
      receiveTime: Date,
      transportMethod: TransportMethod,
      payloadSize: Int,
      encodeTime: TimeInterval,
      decodeTime: TimeInterval
    ) {
      self.sequenceNumber = sequenceNumber
      self.sendTime = sendTime
      self.receiveTime = receiveTime
      self.transportMethod = transportMethod
      self.payloadSize = payloadSize
      self.encodeTime = encodeTime
      self.decodeTime = decodeTime
    }
  }

  /// Recent measurements (limited to last 20)
  @Published public private(set) var measurements: [Measurement] = []

  /// Current sequence number
  @Published public private(set) var currentSequence: Int = 0

  public init() {}

  /// Record a new measurement
  public func recordMeasurement(_ measurement: Measurement) {
    measurements.append(measurement)
    if measurements.count > 20 {
      measurements.removeFirst()
    }
    currentSequence = measurement.sequenceNumber + 1
  }

  /// Average round-trip time
  public var averageRTT: TimeInterval {
    guard !measurements.isEmpty else { return 0 }
    return measurements.map(\.roundTripTime).reduce(0, +) / Double(measurements.count)
  }

  /// Minimum round-trip time
  public var minRTT: TimeInterval {
    measurements.map(\.roundTripTime).min() ?? 0
  }

  /// Maximum round-trip time
  public var maxRTT: TimeInterval {
    measurements.map(\.roundTripTime).max() ?? 0
  }

  /// Standard deviation of round-trip times
  public var standardDeviation: TimeInterval {
    guard measurements.count > 1 else { return 0 }
    let mean = averageRTT
    let variance = measurements
      .map { pow($0.roundTripTime - mean, 2) }
      .reduce(0, +) / Double(measurements.count)
    return sqrt(variance)
  }

  /// Success rate (assumes all recorded measurements were successful)
  public var successRate: Double {
    guard currentSequence > 0 else { return 0 }
    return Double(measurements.count) / Double(currentSequence)
  }

  /// Average encode time
  public var averageEncodeTime: TimeInterval {
    guard !measurements.isEmpty else { return 0 }
    return measurements.map(\.encodeTime).reduce(0, +) / Double(measurements.count)
  }

  /// Average decode time
  public var averageDecodeTime: TimeInterval {
    guard !measurements.isEmpty else { return 0 }
    return measurements.map(\.decodeTime).reduce(0, +) / Double(measurements.count)
  }

  /// Average network time
  public var averageNetworkTime: TimeInterval {
    guard !measurements.isEmpty else { return 0 }
    return measurements.map(\.networkTime).reduce(0, +) / Double(measurements.count)
  }

  /// Clear all measurements
  public func clear() {
    measurements.removeAll()
    currentSequence = 0
  }
}
