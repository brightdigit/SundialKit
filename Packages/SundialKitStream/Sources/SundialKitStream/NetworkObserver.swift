//
//  NetworkObserver.swift
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

public import Foundation
public import SundialKitCore
public import SundialKitNetwork

/// Actor-based network connectivity observer providing AsyncStream APIs
///
/// `NetworkObserver` monitors network connectivity status using Swift concurrency.
/// This is the modern async/await replacement for the Combine-based observer.
///
/// ## Example Usage
///
/// ```swift
/// import SundialKitStream
/// import SundialKitNetwork
///
/// let observer = NetworkObserver(
///   monitor: NWPathMonitorAdapter(),
///   ping: nil
/// )
///
/// await observer.start(queue: .global())
///
/// // AsyncSequence API
/// for await status in observer.pathStatusStream {
///   print("Network status: \(status)")
/// }
/// ```
///
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public actor NetworkObserver<MonitorType: PathMonitor, PingType: NetworkPing> {
  // MARK: - Private Properties

  private let ping: PingType?
  private let monitor: MonitorType
  private var currentPath: MonitorType.PathType?
  private var currentPingStatus: PingType.StatusType?
  private var pathContinuations: [UUID: AsyncStream<MonitorType.PathType>.Continuation] = [:]
  private var pingStatusContinuations: [UUID: AsyncStream<PingType.StatusType>.Continuation] = [:]

  /// Stream of path status changes
  public var pathStatusStream: AsyncStream<PathStatus> {
    AsyncStream { continuation in
      Task {
        for await path in pathUpdates() {
          continuation.yield(path.pathStatus)
        }
        continuation.finish()
      }
    }
  }

  /// Stream of expensive state changes
  public var isExpensiveStream: AsyncStream<Bool> {
    AsyncStream { continuation in
      Task {
        for await path in pathUpdates() {
          continuation.yield(path.isExpensive)
        }
        continuation.finish()
      }
    }
  }

  /// Stream of constrained state changes
  public var isConstrainedStream: AsyncStream<Bool> {
    AsyncStream { continuation in
      Task {
        for await path in pathUpdates() {
          continuation.yield(path.isConstrained)
        }
        continuation.finish()
      }
    }
  }

  // MARK: - Initialization

  internal init(monitor: MonitorType, pingOrNil: PingType?) {
    self.monitor = monitor
    self.ping = pingOrNil

    // Setup callback from monitor
    monitor.onPathUpdate { [weak self] path in
      Task { await self?.handlePathUpdate(path) }
    }
  }

  // MARK: - Public API

  /// Starts monitoring network connectivity
  /// - Parameter queue: The dispatch queue for network monitoring
  public func start(queue: DispatchQueue) {
    monitor.start(queue: queue)
  }

  /// Cancels network monitoring
  public func cancel() {
    monitor.cancel()

    // Finish all active streams
    for continuation in pathContinuations.values {
      continuation.finish()
    }
    pathContinuations.removeAll()

    for continuation in pingStatusContinuations.values {
      continuation.finish()
    }
    pingStatusContinuations.removeAll()
  }

  /// Current network path snapshot
  public func getCurrentPath() -> MonitorType.PathType? {
    currentPath
  }

  /// Current ping status snapshot
  public func getCurrentPingStatus() -> PingType.StatusType? {
    currentPingStatus
  }

  // MARK: - AsyncStream APIs

  /// Stream of path updates
  public func pathUpdates() -> AsyncStream<MonitorType.PathType> {
    AsyncStream { continuation in
      let id = UUID()
      pathContinuations[id] = continuation

      // Send current value immediately if available
      if let currentPath = currentPath {
        continuation.yield(currentPath)
      }

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removePathContinuation(id: id) }
      }
    }
  }

  /// Stream of ping status updates
  public func pingStatusUpdates() -> AsyncStream<PingType.StatusType> {
    AsyncStream { continuation in
      let id = UUID()
      pingStatusContinuations[id] = continuation

      // Send current value immediately if available
      if let currentPingStatus = currentPingStatus {
        continuation.yield(currentPingStatus)
      }

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removePingStatusContinuation(id: id) }
      }
    }
  }

  // MARK: - Internal Handlers
  private func handlePathUpdate(_ path: MonitorType.PathType) {
    currentPath = path

    // Notify all active path stream subscribers
    for continuation in pathContinuations.values {
      continuation.yield(path)
    }
  }

  private func handlePingStatusUpdate(_ status: PingType.StatusType) {
    currentPingStatus = status

    // Notify all active ping status stream subscribers
    for continuation in pingStatusContinuations.values {
      continuation.yield(status)
    }
  }

  private func removePathContinuation(id: UUID) {
    pathContinuations.removeValue(forKey: id)
  }

  private func removePingStatusContinuation(id: UUID) {
    pingStatusContinuations.removeValue(forKey: id)
  }
}
