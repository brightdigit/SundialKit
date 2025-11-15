//
//  MockNetworkPing.swift
//  SundialKitStream
//
//  Created by Leo Dion on 11/14/25.
//

import Foundation

@testable import SundialKitCore
@testable import SundialKitNetwork
@testable import SundialKitStream

internal final class MockNetworkPing: NetworkPing, @unchecked Sendable {
  internal struct StatusType: Sendable, Equatable {
    internal let value: String
  }

  internal private(set) var lastShouldPingStatus: PathStatus?
  internal let id: UUID
  internal let timeInterval: TimeInterval
  internal var shouldPingResponse: Bool
  internal var onPingHandler: ((StatusType) -> Void)?

  internal init(
    id: UUID = UUID(),
    timeInterval: TimeInterval = 1.0,
    shouldPingResponse: Bool = true
  ) {
    self.id = id
    self.timeInterval = timeInterval
    self.shouldPingResponse = shouldPingResponse
  }

  internal func shouldPing(onStatus status: PathStatus) -> Bool {
    lastShouldPingStatus = status
    return shouldPingResponse
  }

  internal func onPing(_ closure: @escaping (StatusType) -> Void) {
    onPingHandler = closure
  }

  internal func sendPingStatus(_ status: StatusType) {
    onPingHandler?(status)
  }
}
