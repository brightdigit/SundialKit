//
//  NetworkMonitor.swift
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

public import Foundation
public import SundialKitCore

/// A protocol for observing network state changes.
///
/// Implement this protocol to receive notifications when network connectivity
/// changes in a ``NetworkMonitor``.
public protocol NetworkStateObserver: AnyObject {
  /// Called when the network path status changes.
  ///
  /// - Parameter status: The new path status
  func networkMonitor(didUpdatePathStatus status: PathStatus)

  /// Called when the expensive network status changes.
  ///
  /// - Parameter isExpensive: Whether the connection is expensive
  func networkMonitor(didUpdateExpensive isExpensive: Bool)

  /// Called when the constrained network status changes.
  ///
  /// - Parameter isConstrained: Whether the connection is constrained
  func networkMonitor(didUpdateConstrained isConstrained: Bool)
}

/// A non-reactive network monitor that implements the `NetworkMonitoring` protocol.
///
/// `NetworkMonitor` provides network connectivity monitoring without requiring Combine,
/// using an observer pattern for state change notifications. It wraps a `PathMonitor`
/// and optionally integrates with `NetworkPing` for connectivity verification.
///
/// ## Thread Safety
///
/// `NetworkMonitor` is thread-safe. All property accesses and observer management
/// use internal locking to prevent data races.
///
/// ## Example Usage
///
/// ```swift
/// #if canImport(Network)
/// import Network
///
/// let monitor = NetworkMonitor(
///   monitor: NWPathMonitor(),
///   ping: nil
/// )
///
/// monitor.start(queue: .global())
///
/// // Access current state
/// print("Status: \(monitor.pathStatus)")
/// print("Expensive: \(monitor.isExpensive)")
/// print("Constrained: \(monitor.isConstrained)")
///
/// // Later, stop monitoring
/// monitor.stop()
/// #endif
/// ```
public final class NetworkMonitor<
  Monitor: PathMonitor,
  Ping: NetworkPing & Sendable
>: NetworkMonitoring, @unchecked Sendable where Monitor.PathType: NetworkPath {
  // MARK: - Helper Types
  private final class WeakObserverBox {
    weak var observer: NetworkStateObserver?
    init(_ observer: NetworkStateObserver) {
      self.observer = observer
    }
  }

  // MARK: - Private Properties
  private let pathMonitor: Monitor
  private let networkPing: Ping?
  private let lock = NSLock()
  private var _pathStatus: PathStatus = .unknown
  private var _isExpensive: Bool = false
  private var _isConstrained: Bool = false
  private var isMonitoring: Bool = false
  private var observers: [WeakObserverBox] = []
  private var pingTimer: DispatchSourceTimer?
  private var pingQueue: DispatchQueue?

  // MARK: - Public Properties (NetworkMonitoring)
  /// The current status of the network path.
  public var pathStatus: PathStatus {
    lock.lock()
    defer { lock.unlock() }
    return _pathStatus
  }

  /// Indicates whether the network connection is expensive.
  public var isExpensive: Bool {
    lock.lock()
    defer { lock.unlock() }
    return _isExpensive
  }

  /// Indicates whether the network connection is constrained.
  public var isConstrained: Bool {
    lock.lock()
    defer { lock.unlock() }
    return _isConstrained
  }

  // MARK: - Initialization
  /// Creates a new network monitor.
  /// - Parameters:
  ///   - monitor: The path monitor to use for tracking network changes
  ///   - ping: Optional network ping for connectivity verification
  public init(monitor: Monitor, ping: Ping?) {
    self.pathMonitor = monitor
    self.networkPing = ping
  }

  // MARK: - Observer Management
  /// Adds an observer to receive network state change notifications.
  /// Observers are held weakly to prevent retain cycles.
  /// - Parameter observer: The observer to add
  public func addObserver(_ observer: NetworkStateObserver) {
    lock.lock()
    defer { lock.unlock() }

    // Remove nil observers
    observers = observers.filter { $0.observer != nil }

    // Add new observer if not already present
    if !observers.contains(where: { $0.observer === observer }) {
      observers.append(WeakObserverBox(observer))
    }
  }

  /// Removes an observer from receiving network state change notifications.
  /// - Parameter observer: The observer to remove
  public func removeObserver(_ observer: NetworkStateObserver) {
    lock.lock()
    defer { lock.unlock() }

    observers = observers.filter { $0.observer !== observer && $0.observer != nil }
  }

  // MARK: - Lifecycle (NetworkMonitoring)
  /// Starts monitoring network connectivity.
  /// - Parameter queue: The dispatch queue on which to deliver network updates
  public func start(queue: DispatchQueue) {
    lock.lock()
    guard !isMonitoring else {
      lock.unlock()
      return
    }
    isMonitoring = true
    lock.unlock()

    // Set up path monitoring
    pathMonitor.onPathUpdate { [weak self] path in
      self?.handlePathUpdate(path)
    }
    pathMonitor.start(queue: queue)

    // Set up ping monitoring if available
    if let ping = networkPing {
      setupPingMonitoring(ping: ping, queue: queue)
    }
  }

  /// Stops monitoring network connectivity.
  public func stop() {
    lock.lock()
    guard isMonitoring else {
      lock.unlock()
      return
    }
    isMonitoring = false
    lock.unlock()

    pathMonitor.cancel()
    stopPingMonitoring()
  }

  // MARK: - Private Methods

  private func handlePathUpdate(_ path: Monitor.PathType) {
    let newStatus = path.pathStatus
    let newExpensive = path.isExpensive
    let newConstrained = path.isConstrained

    var statusChanged = false
    var expensiveChanged = false
    var constrainedChanged = false

    lock.lock()
    if _pathStatus != newStatus {
      _pathStatus = newStatus
      statusChanged = true
    }
    if _isExpensive != newExpensive {
      _isExpensive = newExpensive
      expensiveChanged = true
    }
    if _isConstrained != newConstrained {
      _isConstrained = newConstrained
      constrainedChanged = true
    }

    let currentObservers = observers.compactMap { $0.observer }
    lock.unlock()

    // Notify observers outside of lock
    if statusChanged {
      currentObservers.forEach { $0.networkMonitor(didUpdatePathStatus: newStatus) }
    }
    if expensiveChanged {
      currentObservers.forEach { $0.networkMonitor(didUpdateExpensive: newExpensive) }
    }
    if constrainedChanged {
      currentObservers.forEach { $0.networkMonitor(didUpdateConstrained: newConstrained) }
    }
  }

  private func setupPingMonitoring(ping: Ping, queue: DispatchQueue) {
    pingQueue = queue

    // Use DispatchSourceTimer for better Sendable compliance
    let timer = DispatchSource.makeTimerSource(queue: queue)
    timer.schedule(deadline: .now(), repeating: ping.timeInterval)
    timer.setEventHandler { [weak self] in
      self?.performPing(ping)
    }

    lock.lock()
    pingTimer = timer
    lock.unlock()

    timer.resume()

    // Perform initial ping
    performPing(ping)
  }

  private func performPing(_ ping: Ping) {
    let currentStatus = pathStatus

    guard ping.shouldPing(onStatus: currentStatus) else {
      return
    }

    ping.onPing { [weak self] _ in
      // Ping completed - could update internal state if needed
      // For now, just ensuring the ping executes
      _ = self?.pathStatus
    }
  }

  private func stopPingMonitoring() {
    lock.lock()
    let timer = pingTimer
    pingTimer = nil
    lock.unlock()

    timer?.cancel()
  }
}

// MARK: - Convenience Initializers

extension NetworkMonitor where Ping == NeverPing {
  /// Creates a network monitor without ping support.
  ///
  /// - Parameter monitor: The path monitor to use for tracking network changes
  public convenience init(monitor: Monitor) {
    self.init(monitor: monitor, ping: nil)
  }
}
