//
// TestNetworkStateObserver.swift
// Copyright (c) 2025 BrightDigit.
//

@testable import SundialKitCore
@testable import SundialKitNetwork

internal final class TestNetworkStateObserver: NetworkStateObserver, @unchecked Sendable {
  var pathStatusUpdates: [PathStatus] = []
  var expensiveUpdates: [Bool] = []
  var constrainedUpdates: [Bool] = []

  func networkMonitor(didUpdatePathStatus status: PathStatus) {
    pathStatusUpdates.append(status)
  }

  func networkMonitor(didUpdateExpensive isExpensive: Bool) {
    expensiveUpdates.append(isExpensive)
  }

  func networkMonitor(didUpdateConstrained isConstrained: Bool) {
    constrainedUpdates.append(isConstrained)
  }
}
