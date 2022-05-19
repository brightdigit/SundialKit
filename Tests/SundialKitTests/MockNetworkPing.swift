//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation
import SundialKit

struct MockNetworkStatus {}

class MockNetworkPing: NetworkPing {
  internal init(timeInterval: TimeInterval) {
    self.timeInterval = timeInterval
  }

  public private(set) var lastShoundPingStatus: StatusType?
  let timeInterval: TimeInterval

  func shouldPing(onStatus _: PathStatus) -> Bool {
    false
  }

  func onPing(_: @escaping (StatusType) -> Void) {}

  struct StatusType {}
}
