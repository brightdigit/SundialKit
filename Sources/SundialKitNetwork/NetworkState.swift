//
// NetworkState.swift
// Copyright (c) 2025 BrightDigit.
//

import SundialKitCore

/// Immutable value type representing network connection state.
///
/// `NetworkState` encapsulates the three key aspects of network connectivity:
/// path status, expense, and constraints. This value type is used internally
/// by `NetworkMonitor` for thread-safe state management.
internal struct NetworkState: Equatable, Sendable {
  /// The default initial state with unknown status.
  internal static let initial = NetworkState(
    pathStatus: .unknown,
    isExpensive: false,
    isConstrained: false
  )
  /// The current status of the network path.
  internal let pathStatus: PathStatus

  /// Whether the network connection is expensive (e.g., cellular data).
  internal let isExpensive: Bool

  /// Whether the network connection is constrained (e.g., low data mode).
  internal let isConstrained: Bool
}
