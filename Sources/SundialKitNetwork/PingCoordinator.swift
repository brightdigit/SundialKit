//
//  PingCoordinator.swift
//  SundialKit
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
import SundialKitCore

/// Internal coordinator for managing network ping operations.
///
/// `PingCoordinator` handles the lifecycle of periodic network pings,
/// including timer setup, execution, and cleanup. It is used by
/// `NetworkMonitor` to verify network connectivity.
///
/// ## Thread Safety
///
/// This class uses `@unchecked Sendable` with careful synchronization. This is safe because:
/// - The `ping` and `statusProvider` properties are immutable (let)
/// - The `timer` property is only accessed on the dispatch queue where it was created
/// - Timer event handlers execute on the same queue, preventing concurrent access
/// - All timer operations (start/stop) are serialized on the queue
internal final class PingCoordinator<Ping: NetworkPing & Sendable>: @unchecked Sendable {
  // MARK: - Private Properties

  private let ping: Ping
  private let statusProvider: () -> PathStatus
  private var timer: (any DispatchSourceTimer)?

  // MARK: - Initialization

  /// Creates a new ping coordinator.
  ///
  /// - Parameters:
  ///   - ping: The network ping implementation
  ///   - statusProvider: Closure that provides the current path status
  internal init(
    ping: Ping,
    statusProvider: @escaping () -> PathStatus
  ) {
    self.ping = ping
    self.statusProvider = statusProvider
  }

  // MARK: - Lifecycle Methods

  /// Starts periodic ping monitoring.
  ///
  /// - Parameter queue: The dispatch queue on which to schedule pings
  internal func start(queue: DispatchQueue) {
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.schedule(deadline: .now(), repeating: ping.timeInterval)
    timer.setEventHandler { [weak self] in
      self?.performPing()
    }

    self.timer = timer
    timer.resume()

    // Perform initial ping
    performPing()
  }

  /// Stops ping monitoring and cancels the timer.
  internal func stop() {
    timer?.cancel()
    timer = nil
  }

  // MARK: - Private Methods

  private func performPing() {
    let currentStatus = statusProvider()

    guard ping.shouldPing(onStatus: currentStatus) else {
      return
    }

    ping.onPing { _ in
      // Ping completed - NetworkMonitor will handle any state updates
    }
  }
}
