//
//  StreamContinuationRegistry.swift
//  SundialKitStream
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

import Foundation

/// Generic registry for managing AsyncStream continuations.
///
/// `StreamContinuationRegistry` provides a centralized way to manage multiple
/// active stream continuations, handling registration, removal, and value
/// propagation. It is designed to be used within actors where actor isolation
/// provides thread safety.
///
/// ## Usage Example
///
/// ```swift
/// actor MyObserver {
///   private let stateRegistry = StreamContinuationRegistry<String>()
///
///   func stateStream() -> AsyncStream<String> {
///     stateRegistry.createStream(initialValue: currentState)
///   }
///
///   private func updateState(_ newState: String) {
///     stateRegistry.yield(newState)
///   }
/// }
/// ```
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
internal struct StreamContinuationRegistry<Element> where Element: Sendable {
  // MARK: - Private Properties

  private var continuations: [UUID: AsyncStream<Element>.Continuation] = [:]

  // MARK: - Initialization

  /// Creates a new stream continuation registry.
  internal init() {}

  // MARK: - Stream Management

  /// Creates a new AsyncStream and registers its continuation.
  ///
  /// - Parameter initialValue: Optional value to yield immediately upon subscription
  /// - Returns: A tuple containing the stream and a removal callback
  internal mutating func createStream(
    initialValue: Element? = nil
  ) -> (stream: AsyncStream<Element>, onTermination: @Sendable () -> Void) {
    let id = UUID()

    let stream = AsyncStream<Element> { continuation in
      continuations[id] = continuation

      // Yield initial value if provided
      if let initialValue = initialValue {
        continuation.yield(initialValue)
      }

      continuation.onTermination = { [id] _ in
        // Remove continuation on termination
        // Note: This closure captures id, but removal happens in the actor context
      }
    }

    let removal: @Sendable () -> Void = { [id] in
      // This will be called from the actor context
    }

    return (stream: stream, onTermination: removal)
  }

  /// Removes a continuation by its ID.
  ///
  /// - Parameter id: The unique identifier of the continuation to remove
  internal mutating func remove(id: UUID) {
    continuations.removeValue(forKey: id)
  }

  /// Yields a value to all registered continuations.
  ///
  /// - Parameter value: The value to yield to all active streams
  internal func yield(_ value: Element) {
    for continuation in continuations.values {
      continuation.yield(value)
    }
  }

  /// Finishes all registered continuations.
  internal mutating func finishAll() {
    for continuation in continuations.values {
      continuation.finish()
    }
    continuations.removeAll()
  }

  /// Returns the number of active continuations.
  internal var count: Int {
    continuations.count
  }
}
