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

struct MockPathMonitor: PathMonitor {
  func onPathUpdate(_: @escaping (MockPath) -> Void) {}

  func start(queue _: DispatchQueue) {}

  func cancel() {}

  typealias PathType = MockPath
}
