//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation
import SundialKit

internal class MockNetworkPing: NetworkPing {
  internal init(id: UUID, timeInterval: TimeInterval) {
    self.id = id
    self.timeInterval = timeInterval
  }

  internal private(set) var lastShoundPingStatus: StatusType?
  internal let id: UUID
  internal let timeInterval: TimeInterval

  internal func shouldPing(onStatus _: PathStatus) -> Bool {
    true
  }

  internal func onPing(_ closure: @escaping (StatusType) -> Void) {
    closure(.init())
  }

  internal struct StatusType {}
}
