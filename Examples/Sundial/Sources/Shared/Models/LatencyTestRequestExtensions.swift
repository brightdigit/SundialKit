//
//  LatencyTestRequestExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance and helpers for LatencyTestRequest.
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

// MARK: - BinaryMessagable Conformance

extension Sundial_Demo_LatencyTestRequest: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
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
