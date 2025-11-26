//
// ConnectivityObserverManaging+Actor.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore

  // MARK: - Default Implementations for Actor-Based Observer Management

  extension ConnectivityObserverManaging where Self: Actor {
    /// Adds an observer for state changes.
    ///
    /// This method awaits the completion of observer registration
    /// on the actor's isolation domain.
    ///
    /// - Parameter observer: The observer to add.
    /// - Note: Observers are stored with strong references - caller must manage lifecycle.
    public func addObserver(_ observer: any ConnectivityStateObserver) async {
      await observerRegistry.add(observer)
    }

    /// Removes observers matching the predicate.
    ///
    /// This method awaits the completion of observer removal
    /// on the actor's isolation domain.
    ///
    /// - Parameter predicate: Closure to identify observers to remove.
    public func removeObservers(
      where predicate: @Sendable @escaping (any ConnectivityStateObserver) -> Bool
    ) async {
      await observerRegistry.removeAll(where: predicate)
    }
  }
#endif
