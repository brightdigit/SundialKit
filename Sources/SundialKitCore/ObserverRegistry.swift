//
//  ObserverRegistry.swift
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

import Foundation

/// A thread-safe registry for managing observer references.
///
/// `ObserverRegistry` provides thread-safe access to the observer list.
/// Observers are held strongly - callers must manage lifecycle.
///
/// ## Thread Safety
///
/// This actor ensures thread-safe access to observer state. Public methods are
/// `nonisolated` and use Tasks internally for actor-isolated operations.
///
/// ## Usage Example
///
/// ```swift
/// protocol MyObserver: Sendable {
///   func didUpdate(value: Int)
/// }
///
/// actor Subject {
///   private let observers = ObserverRegistry<MyObserver>()
///
///   func addObserver(_ observer: MyObserver) {
///     observers.add(observer)
///   }
///
///   func notifyObservers(value: Int) {
///     observers.notify { $0.didUpdate(value: value) }
///   }
/// }
/// ```
public actor ObserverRegistry<Observer: Sendable> {
  // MARK: - Private Properties

  private var observers: [Observer] = []

  // MARK: - Initialization

  /// Creates a new observer registry.
  public init() {}

  // MARK: - Public Methods

  /// Adds an observer to the registry.
  ///
  /// The observer is held strongly - caller must manage lifecycle.
  ///
  /// - Parameter observer: The observer to add
  public func add(_ observer: Observer) {
    observers.append(observer)
  }

  /// Removes all instances of an observer from the registry.
  ///
  /// Note: Requires Observer to be Equatable for removal.
  /// Consider using a wrapper with identity if needed.
  ///
  /// - Parameter predicate: Defines which observers to remove.
  public func removeAll(where predicate: @Sendable (Observer) -> Bool) {
    observers.removeAll(where: predicate)
  }

  /// Notifies all registered observers by executing the provided action.
  ///
  /// - Parameter action: The closure to execute for each observer
  public nonisolated func notify(_ action: @Sendable @escaping (Observer) async -> Void) {
    Task {
      await notifyIsolated(action)
    }
  }

  // MARK: - Actor-Isolated Methods

  private func notifyIsolated(_ action: @Sendable (Observer) async -> Void) async {
    for observer in observers {
      await action(observer)
    }
  }

  /// Returns a snapshot of all currently registered observers.
  ///
  /// - Returns: Array of active observers
  public func snapshot() -> [Observer] {
    observers
  }
}
