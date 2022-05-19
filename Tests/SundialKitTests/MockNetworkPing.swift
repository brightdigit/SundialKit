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
  internal init(id: UUID, timeInterval: TimeInterval) {
    self.id = id
    self.timeInterval = timeInterval
  }

  public private(set) var lastShoundPingStatus: StatusType?
  let id : UUID
  let timeInterval: TimeInterval

  func shouldPing(onStatus _: PathStatus) -> Bool {
    true 
  }
  
  func onPing(_ closure: @escaping (StatusType) -> Void) {
    closure(.init())
  }

  struct StatusType {}
}
