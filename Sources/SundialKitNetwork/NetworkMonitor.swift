//
// NetworkMonitor.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// A non-reactive network monitor that implements the `NetworkMonitoring` protocol.
///
/// `NetworkMonitor` provides network connectivity monitoring without requiring Combine,
/// using an observer pattern for state change notifications. It wraps a `PathMonitor`
/// and optionally integrates with `NetworkPing` for connectivity verification.
///
/// ## Thread Safety
///
/// This actor ensures thread-safe access to network state. Public methods are
/// `nonisolated` and use Tasks internally for actor-isolated operations, providing
/// a synchronous API while maintaining thread safety
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
public actor NetworkMonitor<
  Monitor: PathMonitor,
  Ping: NetworkPing & Sendable
>: NetworkMonitoring where Monitor.PathType: NetworkPath {
  // MARK: - Private Properties
  private let pathMonitor: Monitor
  private let networkPing: Ping?
  private var state: NetworkState = .initial
  private var isMonitoring: Bool = false
  private let observers = ObserverRegistry<any NetworkStateObserver>()
  private var pingCoordinator: PingCoordinator<Ping>?

  // MARK: - Public Properties (NetworkMonitoring)
  /// The current status of the network path.
  nonisolated public var pathStatus: PathStatus {
    get async {
      await state.pathStatus
    }
  }

  /// Indicates whether the network connection is expensive.
  nonisolated public var isExpensive: Bool {
    get async {
      await state.isExpensive
    }
  }

  /// Indicates whether the network connection is constrained.
  nonisolated public var isConstrained: Bool {
    get async {
      await state.isConstrained
    }
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
  /// Observers are held strongly - caller must manage lifecycle.
  /// - Parameter observer: The observer to add
  public func addObserver(_ observer: any NetworkStateObserver) async {
    await observers.add(observer)
  }

  /// Removes observers matching the predicate.
  /// - Parameter predicate: Closure to identify observers to remove
  public func removeObservers(
    where predicate: @Sendable @escaping (any NetworkStateObserver) -> Bool
  ) async {
    await observers.removeAll(where: predicate)
  }

  // MARK: - Lifecycle (NetworkMonitoring)
  /// Starts monitoring network connectivity.
  /// - Parameter queue: The dispatch queue on which to deliver network updates
  nonisolated public func start(queue: DispatchQueue) {
    Task {
      await startIsolated(queue: queue)
    }
  }

  /// Stops monitoring network connectivity.
  nonisolated public func stop() {
    Task {
      await stopIsolated()
    }
  }

  // MARK: - Actor-Isolated Lifecycle Methods

  private func startIsolated(queue: DispatchQueue) {
    guard !isMonitoring else {
      return
    }
    isMonitoring = true

    // Set up path monitoring
    pathMonitor.onPathUpdate { [weak self] path in
      Task {
        await self?.handlePathUpdate(path)
      }
    }
    pathMonitor.start(queue: queue)

    // Set up ping monitoring if available
    if let ping = networkPing {
      let currentState = state
      let coordinator = PingCoordinator(ping: ping) {
        // Capture state at creation time for synchronous access
        currentState.pathStatus
      }
      coordinator.start(queue: queue)
      pingCoordinator = coordinator
    }
  }

  private func stopIsolated() {
    guard isMonitoring else {
      return
    }
    isMonitoring = false
    let coordinator = pingCoordinator
    pingCoordinator = nil

    pathMonitor.cancel()
    coordinator?.stop()
  }

  // MARK: - Private Methods

  private func handlePathUpdate(_ path: Monitor.PathType) async {
    let newState = NetworkState(
      pathStatus: path.pathStatus,
      isExpensive: path.isExpensive,
      isConstrained: path.isConstrained
    )

    let oldState = state
    state = newState

    // Notify observers
    if oldState.pathStatus != newState.pathStatus {
      await observers.notify { observer in
        await observer.networkMonitor(didUpdatePathStatus: newState.pathStatus)
      }
    }
    if oldState.isExpensive != newState.isExpensive {
      await observers.notify { observer in
        await observer.networkMonitor(didUpdateExpensive: newState.isExpensive)
      }
    }
    if oldState.isConstrained != newState.isConstrained {
      await observers.notify { observer in
        await observer.networkMonitor(didUpdateConstrained: newState.isConstrained)
      }
    }
  }
}

// MARK: - Convenience Initializers

extension NetworkMonitor where Ping == NeverPing {
  /// Creates a network monitor without ping support.
  ///
  /// - Parameter monitor: The path monitor to use for tracking network changes
  public init(monitor: Monitor) {
    self.init(monitor: monitor, ping: nil)
  }
}
