//
//  MockPathMonitor.swift
//  SundialKitStream
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

@testable import SundialKitCore
@testable import SundialKitNetwork
@testable import SundialKitStream

// MARK: - Mock Implementations

internal final class MockPathMonitor: PathMonitor, @unchecked Sendable {
  internal typealias PathType = MockPath

  internal let id: UUID
  internal private(set) var pathUpdate: ((MockPath) -> Void)?
  internal private(set) var dispatchQueueLabel: String?
  internal private(set) var isCancelled = false

  internal init(id: UUID = UUID()) {
    self.id = id
  }

  internal func onPathUpdate(_ handler: @escaping (MockPath) -> Void) {
    pathUpdate = handler
  }

  internal func start(queue: DispatchQueue) {
    dispatchQueueLabel = queue.label
    // Immediately send an initial path
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
}

internal struct MockPath: NetworkPath {
  internal let isConstrained: Bool
  internal let isExpensive: Bool
  internal let pathStatus: PathStatus

  internal init(
    isConstrained: Bool = false,
    isExpensive: Bool = false,
    pathStatus: PathStatus = .unknown
  ) {
    self.isConstrained = isConstrained
    self.isExpensive = isExpensive
    self.pathStatus = pathStatus
  }
}

internal final class MockNetworkPing: NetworkPing, @unchecked Sendable {
  internal struct StatusType: Sendable, Equatable {
    let value: String
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
