//
// ObserverRegistry.swift
// Copyright (c) 2025 BrightDigit.
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
  public func notify(_ action: @Sendable @escaping (Observer) async -> Void) async {
    await notifyIsolated(action)
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
