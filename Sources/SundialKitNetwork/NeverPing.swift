//
// NeverPing.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// `NetworkPing` which is never called.
/// This used for a `NetworkObserver` that doesn't need a continuous ping.
public struct NeverPing: NetworkPing, Sendable {
  /// The ping status type (Never, since this implementation never pings).
  public typealias StatusType = Never

  /// The time interval for pings (NaN, since this implementation never pings).
  public var timeInterval: TimeInterval {
    .nan
  }

  private init() {}

  /// Determines whether a ping should be performed (always returns false).
  ///
  /// - Returns: Always false
  public func shouldPing(onStatus _: PathStatus) -> Bool {
    false
  }

  /// Sets the ping handler (no-op, since this implementation never pings).
  public func onPing(_: @escaping (Never) -> Void) {}
}
