//
//  NetworkState.swift
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

import SundialKitCore

/// Immutable value type representing network connection state.
///
/// `NetworkState` encapsulates the three key aspects of network connectivity:
/// path status, expense, and constraints. This value type is used internally
/// by `NetworkMonitor` for thread-safe state management.
internal struct NetworkState: Equatable, Sendable {
  /// The current status of the network path.
  internal let pathStatus: PathStatus

  /// Whether the network connection is expensive (e.g., cellular data).
  internal let isExpensive: Bool

  /// Whether the network connection is constrained (e.g., low data mode).
  internal let isConstrained: Bool

  /// The default initial state with unknown status.
  internal static let initial = NetworkState(
    pathStatus: .unknown,
    isExpensive: false,
    isConstrained: false
  )
}
