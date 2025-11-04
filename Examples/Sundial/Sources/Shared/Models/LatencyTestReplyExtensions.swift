//
//  LatencyTestReplyExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance and helpers for LatencyTestReply.
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

// MARK: - BinaryMessagable Conformance

extension Sundial_Demo_LatencyTestReply: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
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
