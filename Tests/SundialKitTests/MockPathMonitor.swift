//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation
import SundialKit

internal class MockPathMonitor: PathMonitor {
  internal private(set) var pathUpdate: ((MockPath) -> Void)?
  internal private(set) var dispatchQueueLabel: String?
  internal private(set) var isCancelled = false
  internal init(id: UUID) {
    self.id = id
  }

  internal let id: UUID

  internal func onPathUpdate(_ handler: @escaping (MockPath) -> Void) {
    pathUpdate = handler
  }

  internal func start(queue: DispatchQueue) {
    dispatchQueueLabel = queue.label
    pathUpdate?(
      .init(
        isConstrained: false,
        isExpensive: false,
        pathStatus: .satisfied(.wiredEthernet)
      )
    )
  }

  internal func cancel() {
    isCancelled = true
  }

  internal func sendPath(_ path: MockPath) {
    pathUpdate?(path)
  }

  internal typealias PathType = MockPath
}
