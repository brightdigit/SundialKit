//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation
import SundialKit

struct MockPath: NetworkPath {
  var isConstrained: Bool

  var isExpensive: Bool

  var pathStatus: PathStatus
}

class MockPathMonitor: PathMonitor {
  
  var dispatchQueueLabel : String? = nil
  internal init(id: UUID) {
    self.id = id
  }
  
  let id : UUID
  func onPathUpdate(_: @escaping (MockPath) -> Void) {}

  func start(queue: DispatchQueue) {
    self.dispatchQueueLabel = queue.label
  }

  func cancel() {}

  typealias PathType = MockPath
}
