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

/// A thread-safe registry for managing weak references to observer objects.
///
/// `ObserverRegistry` provides automatic cleanup of deallocated observers and
/// thread-safe access to the observer list. Observers are held weakly to prevent
/// retain cycles.
///
/// ## Usage Example
///
/// ```swift
/// protocol MyObserver: AnyObject {
///   func didUpdate(value: Int)
/// }
///
/// class Subject {
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
public final class ObserverRegistry<Observer>: @unchecked Sendable {
  // MARK: - Helper Types

  /// Weak wrapper for observer references using AnyObject.
  private final class WeakBox {
    weak var observer: AnyObject?

    init(_ observer: AnyObject) {
      self.observer = observer
    }
  }

  // MARK: - Private Properties

  private let lock = NSLock()
  private var observers: [WeakBox] = []

  // MARK: - Initialization

  /// Creates a new observer registry.
  public init() {}

  // MARK: - Public Methods

  /// Adds an observer to the registry.
  ///
  /// If the observer is already registered, this method has no effect.
  /// The observer is held weakly to prevent retain cycles.
  ///
  /// - Parameter observer: The observer to add
  public func add(_ observer: Observer) {
    guard let anyObject = observer as? AnyObject else {
      return
    }

    lock.lock()
    defer { lock.unlock() }

    // Remove nil observers during cleanup
    observers = observers.filter { $0.observer != nil }

    // Add new observer if not already present
    if !observers.contains(where: { $0.observer === anyObject }) {
      observers.append(WeakBox(anyObject))
    }
  }

  /// Removes an observer from the registry.
  ///
  /// - Parameter observer: The observer to remove
  public func remove(_ observer: Observer) {
    guard let anyObject = observer as? AnyObject else {
      return
    }

    lock.lock()
    defer { lock.unlock() }

    observers = observers.filter { $0.observer !== anyObject && $0.observer != nil }
  }

  /// Notifies all registered observers by executing the provided action.
  ///
  /// The action is executed outside of the lock to prevent potential deadlocks.
  /// Deallocated observers are automatically skipped.
  ///
  /// - Parameter action: The closure to execute for each observer
  public func notify(_ action: (Observer) -> Void) {
    let currentObservers = snapshot()

    for observer in currentObservers {
      action(observer)
    }
  }

  /// Returns a snapshot of all currently registered observers.
  ///
  /// This method is useful when you need to iterate over observers manually
  /// or check the current observer count.
  ///
  /// - Returns: Array of active observers
  public func snapshot() -> [Observer] {
    lock.lock()
    defer { lock.unlock() }

    return observers.compactMap { $0.observer as? Observer }
  }
}
