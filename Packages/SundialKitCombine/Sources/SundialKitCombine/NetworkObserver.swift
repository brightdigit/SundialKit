//
//  NetworkObserver.swift
//  SundialKitCombine
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

#if canImport(Combine)
  public import Combine
  public import Foundation
  public import SundialKitCore
  public import SundialKitNetwork

  /// MainActor-isolated network observer providing Combine publishers
  ///
  /// `NetworkObserver` provides reactive network monitoring using Combine framework.
  /// All state updates occur on the main thread, making it safe for UI integration.
  ///
  /// ## Example Usage
  ///
  /// ```swift
  /// import SundialKitCombine
  ///
  /// let observer = NetworkObserver()
  /// observer.start()
  ///
  /// // Observe path status changes
  /// observer.$pathStatus
  ///   .sink { status in
  ///     print("Network status: \(status)")
  ///   }
  ///   .store(in: &cancellables)
  ///
  /// // Observe reachability
  /// observer.$isReachable
  ///   .sink { isReachable in
  ///     print("Reachable: \(isReachable)")
  ///   }
  ///   .store(in: &cancellables)
  /// ```
  ///
  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  @MainActor
  public final class NetworkObserver<MonitorType: PathMonitor, PingType: NetworkPing & Sendable> {
    // MARK: - Published Properties

    /// Current network path status
    @Published public private(set) var pathStatus: PathStatus = .unknown

    /// Whether the network is expensive (cellular, personal hotspot, etc.)
    @Published public private(set) var isExpensive: Bool = false

    /// Whether the network is constrained (low data mode)
    @Published public private(set) var isConstrained: Bool = false

    /// Current ping status (if ping is enabled)
    @Published public private(set) var pingStatus: PingType.StatusType?

    // MARK: - Private Properties

    private let monitor: MonitorType
    private let ping: PingType?
    private let queue: DispatchQueue
    private var timer: Timer?

    // MARK: - Initialization

    /// MainActor-isolated network observer providing Combine publishers
    /// - Parameters:
    ///   - monitor: A ``PathMonitor``.
    ///   - ping: A ``NetworkPing``
    ///   - queue: Dispatch Queue to monitor on.
    public init(monitor: MonitorType, ping: PingType?, queue: DispatchQueue = .main) {
      self.monitor = monitor
      self.ping = ping
      self.queue = queue
    }

    // MARK: - Public API

    /// Starts monitoring network changes
    public func start() {
      monitor.onPathUpdate { [weak self] path in
        Task { @MainActor in
          self?.handlePathUpdate(path)
        }
      }
      monitor.start(queue: queue)

      if let ping = ping {
        setupPingTimer(ping)
      }
    }

    /// Stops monitoring network changes
    public func stop() {
      monitor.cancel()
      timer?.invalidate()
      timer = nil
    }

    // MARK: - Private Methods

    private func handlePathUpdate(_ path: MonitorType.PathType) {
      pathStatus = path.pathStatus
      isExpensive = path.isExpensive
      isConstrained = path.isConstrained
    }

    private func setupPingTimer(_ ping: PingType) {
      let timer = Timer.scheduledTimer(
        withTimeInterval: ping.timeInterval,
        repeats: true
      ) { [weak self] _ in
        Task { @MainActor in
          self?.performPing(ping)
        }
      }
      self.timer = timer
    }

    private func performPing(_ ping: PingType) {
      guard ping.shouldPing(onStatus: pathStatus) else {
        return
      }

      ping.onPing { [weak self] status in
        Task { @MainActor in
          self?.pingStatus = status
        }
      }
    }
  }

  // MARK: - Convenience Initializers

  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension NetworkObserver where PingType == NeverPing {
    /// Creates a network observer without ping functionality
    public convenience init(monitor: MonitorType, queue: DispatchQueue = .main) {
      self.init(monitor: monitor, ping: nil, queue: queue)
    }
  }

  #if canImport(Network)
    public import Network

    @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
    extension NetworkObserver where MonitorType == NWPathMonitor, PingType == NeverPing {
      /// Creates `NetworkObserver` with default `NWPathMonitor` and no ping
      ///
      /// This is the simplest way to create a network observer for most use cases.
      /// The observer uses Apple's `NWPathMonitor` to track network connectivity
      /// changes without ping-based verification. The observer is @MainActor isolated,
      /// making it safe to use directly with SwiftUI.
      ///
      /// ## Example Usage
      ///
      /// ```swift
      /// import SundialKitCombine
      ///
      /// let observer = NetworkObserver()
      /// observer.start()
      ///
      /// observer.$pathStatus
      ///   .sink { status in
      ///     print("Network status: \(status)")
      ///   }
      ///   .store(in: &cancellables)
      /// ```
      ///
      /// - Parameter queue: The dispatch queue for network monitoring (defaults to `.main`)
      public convenience init(queue: DispatchQueue = .main) {
        self.init(monitor: NWPathMonitor(), ping: nil, queue: queue)
      }
    }
  #endif
#endif
