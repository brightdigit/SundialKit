//
//  File.swift
//
//
//  Created by Leo Dion on 5/19/22.
//
import Foundation
import SundialKit

struct MockPath: NetworkPath {
  internal init(
    isConstrained: Bool = false,
    isExpensive: Bool = false,
    pathStatus: PathStatus = .unknown
  ) {
    self.isConstrained = isConstrained
    self.isExpensive = isExpensive
    self.pathStatus = pathStatus
  }

  let isConstrained: Bool

  let isExpensive: Bool

  let pathStatus: PathStatus
}

class MockPathMonitor: PathMonitor {
  public private(set) var pathUpdate: ((MockPath) -> Void)?
  public private(set) var dispatchQueueLabel: String?
  public private(set) var isCancelled = false
  internal init(id: UUID) {
    self.id = id
  }

  let id: UUID

  func onPathUpdate(_ handler: @escaping (MockPath) -> Void) {
    pathUpdate = handler
  }

  func start(queue: DispatchQueue) {
    dispatchQueueLabel = queue.label
    pathUpdate?(
      .init(
        isConstrained: false,
        isExpensive: false,
        pathStatus: .satisfied(.wiredEthernet)
      )
    )
  }

  func cancel() {
    isCancelled = true
  }

  func sendPath(_ path: MockPath) {
    pathUpdate?(path)
  }

  typealias PathType = MockPath
}
