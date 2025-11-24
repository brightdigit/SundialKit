//
//  LatencyStatsExtensions.swift
//  Sundial Demo
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  BinaryMessagable conformance for LatencyStats.
//

import Foundation
import SundialKitConnectivity
import SwiftProtobuf

// MARK: - BinaryMessagable Conformance

extension Sundial_Demo_LatencyStats: BinaryMessagable {
  public init(from data: Data) throws {
    try self.init(serializedData: data)
  }

  public func encode() throws -> Data {
    try serializedData()
  }
}
