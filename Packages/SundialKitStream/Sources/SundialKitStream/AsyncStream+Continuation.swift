//
//  AsyncStream+Continuation.swift
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

public import Foundation

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension AsyncStream {
  /// Creates an AsyncStream with automatic continuation management
  ///
  /// This convenience initializer encapsulates the common pattern of:
  /// 1. Generating a unique ID for each stream subscriber
  /// 2. Registering a continuation with a continuation manager
  /// 3. Optionally yielding an initial value immediately
  /// 4. Setting up automatic cleanup on termination
  ///
  /// ## Example
  ///
  /// ```swift
  /// public func activationStates() -> AsyncStream<ActivationState> {
  ///   AsyncStream(
  ///     register: { id, cont in
  ///       await self.manager.register(id: id, continuation: cont)
  ///     },
  ///     unregister: { id in
  ///       await self.manager.unregister(id: id)
  ///     },
  ///     initialValue: { await self.currentState }
  ///   )
  /// }
  /// ```
  ///
  /// - Parameters:
  ///   - register: Closure to register the continuation with a manager
  ///   - unregister: Closure to remove the continuation from the manager
  ///   - initialValue: Optional closure to get an initial value to yield immediately
  public init(
    register: @escaping @Sendable (UUID, Continuation) async -> Void,
    unregister: @escaping @Sendable (UUID) async -> Void,
    initialValue: (@Sendable () async -> Element?)? = nil
  ) {
    self.init { continuation in
      let id = UUID()
      Task {
        await register(id, continuation)

        // Yield initial value if provided
        if let initialValue = initialValue {
          if let value = await initialValue() {
            continuation.yield(value)
          }
        }
      }

      continuation.onTermination = { _ in
        Task {
          await unregister(id)
        }
      }
    }
  }
}
