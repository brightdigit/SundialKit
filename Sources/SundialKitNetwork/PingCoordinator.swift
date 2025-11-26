//
// PingCoordinator.swift
// Copyright (c) 2025 BrightDigit.
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
