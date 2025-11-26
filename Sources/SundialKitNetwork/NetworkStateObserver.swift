//
// NetworkStateObserver.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// A protocol for observing network state changes.
///
/// Implement this protocol to receive notifications when network connectivity
/// changes in a ``NetworkMonitor``.
///
/// Observers must be Sendable (actors, @MainActor classes, or value types).
public protocol NetworkStateObserver: Sendable {
  /// Called when the network path status changes.
  ///
  /// - Parameter status: The new path status
  func networkMonitor(didUpdatePathStatus status: PathStatus) async

  /// Called when the expensive network status changes.
  ///
  /// - Parameter isExpensive: Whether the connection is expensive
  func networkMonitor(didUpdateExpensive isExpensive: Bool) async

  /// Called when the constrained network status changes.
  ///
  /// - Parameter isConstrained: Whether the connection is constrained
  func networkMonitor(didUpdateConstrained isConstrained: Bool) async
}
