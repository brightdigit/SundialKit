//
//  NetworkMonitoring.swift
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

/// A protocol for monitoring network connectivity status and characteristics.
///
/// Types conforming to `NetworkMonitoring` provide real-time information about
/// network connectivity, including path status, cost characteristics, and data constraints.
/// This protocol serves as the foundation for various reactive implementations
/// (Combine-based, AsyncStream-based) of network monitoring.
///
/// ## Topics
///
/// ### Network State
/// - ``pathStatus``
/// - ``isExpensive``
/// - ``isConstrained``
///
/// ### Lifecycle
/// - ``start(queue:)``
/// - ``stop()``
///
/// ## Example Usage
///
/// Implementing a basic network monitor:
///
/// ```swift
/// class BasicNetworkMonitor: NetworkMonitoring {
///     private(set) var pathStatus: PathStatus = .unknown
///     private(set) var isExpensive: Bool = false
///     private(set) var isConstrained: Bool = false
///
///     func start(queue: DispatchQueue) {
///         // Begin monitoring network changes
///     }
///
///     func stop() {
///         // Stop monitoring
///     }
/// }
/// ```
public protocol NetworkMonitoring {
  /// The current status of the network path.
  ///
  /// This property indicates whether the network is available, the type of interface
  /// being used (cellular, wifi, etc.), and any reasons why the network might be
  /// unavailable.
  ///
  /// - SeeAlso: ``PathStatus``
  var pathStatus: PathStatus { get async }

  /// Indicates whether the network connection is expensive.
  ///
  /// A connection is considered expensive when:
  /// - Using cellular data with limited data plans
  /// - Connected to a personal hotspot
  /// - Using certain VPN configurations
  ///
  /// Apps should minimize data usage when this property is `true` to respect
  /// user preferences and data plan limits.
  var isExpensive: Bool { get async }

  /// Indicates whether the network connection is constrained.
  ///
  /// A connection is constrained when the system has enabled Low Data Mode,
  /// either at the system level or for specific networks. Apps should:
  /// - Defer large transfers
  /// - Reduce image quality
  /// - Disable background updates
  /// - Minimize network usage
  ///
  /// This helps users conserve data and battery life.
  var isConstrained: Bool { get async }

  /// Starts monitoring network connectivity.
  ///
  /// After calling this method, the monitor begins observing network changes
  /// and updating its properties accordingly. Implementations should use the
  /// provided queue for all network-related callbacks.
  ///
  /// - Parameter queue: The dispatch queue on which to deliver network updates.
  ///
  /// - Note: Call this method before accessing network state properties to ensure
  ///   accurate, up-to-date information.
  func start(queue: DispatchQueue)

  /// Stops monitoring network connectivity.
  ///
  /// After calling this method, the monitor ceases observing network changes.
  /// Implementations should clean up any resources and cancel pending operations.
  ///
  /// - Note: It's safe to call this method multiple times. The monitor can be
  ///   restarted by calling ``start(queue:)`` again.
  func stop()
}
