//
// NetworkPath.swift
// Copyright (c) 2025 BrightDigit.
//

public import SundialKitCore

/// A path which contains information about the network connections.
public protocol NetworkPath {
  /// Whether the network path is constrained.
  var isConstrained: Bool { get }
  /// Whether the network path is expensive.
  var isExpensive: Bool { get }
  /// The status of the network connection.
  var pathStatus: PathStatus { get }
}
