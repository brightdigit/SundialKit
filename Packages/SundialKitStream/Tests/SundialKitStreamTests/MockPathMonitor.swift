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
