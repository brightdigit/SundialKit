//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation

@testable import SundialKitCore
@testable import SundialKitNetwork

internal class MockNetworkPing: NetworkPing {
  internal struct StatusType {}
  internal private(set) var lastShoundPingStatus: StatusType?
  internal let id: UUID
  internal let timeInterval: TimeInterval

  internal init(id: UUID, timeInterval: TimeInterval) {
    self.id = id
    self.timeInterval = timeInterval
  }

  internal func shouldPing(onStatus _: PathStatus) -> Bool {
    true
  }

  internal func onPing(_ closure: @escaping (StatusType) -> Void) {
    closure(.init())
  }
}
