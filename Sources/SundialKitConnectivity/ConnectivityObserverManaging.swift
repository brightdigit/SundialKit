//
// ConnectivityObserverManaging.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore

  /// Protocol for managing connectivity state observers.
  ///
  /// This protocol defines the interface for adding and removing observers
  /// that receive notifications about connectivity state changes.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityObserverManaging {
    /// Registry for managing observer references.
    var observerRegistry: ObserverRegistry<any ConnectivityStateObserver> { get }

    /// Adds an observer for state changes.
    ///
    /// - Parameter observer: The observer to add.
    func addObserver(_ observer: any ConnectivityStateObserver) async

    /// Removes a specific observer.
    ///
    /// - Parameter observer: The observer to remove.
    func removeObserver(_ observer: any ConnectivityStateObserver) async

    /// Removes observers matching the predicate.
    ///
    /// - Parameter predicate: Closure to identify observers to remove.
    func removeObservers(
      where predicate: @Sendable @escaping (any ConnectivityStateObserver) -> Bool) async
  }

  // MARK: - Default Implementation

  extension ConnectivityObserverManaging {
    /// Default implementation for removing a specific observer.
    ///
    /// Uses identity comparison to match observers.
    ///
    /// - Parameter observer: The observer to remove.
    public func removeObserver(_ observer: any ConnectivityStateObserver) async {
      await removeObservers { storedObserver in
        // Compare by object identity
        guard let lhs = storedObserver as AnyObject?,
          let rhs = observer as AnyObject?
        else {
          return false
        }
        return lhs === rhs
      }
    }
  }

  // MARK: - Default Notification Methods

  extension ConnectivityObserverManaging where Self: ConnectivityManager {
    /// Notifies observers of activation state change.
    ///
    /// Observers are responsible for thread management.
    /// Use @MainActor on your observer for UI updates.
    internal func notifyActivationStateChanged(_ state: ActivationState) async {
      await observerRegistry.notify { observer in
        observer.connectivityManager(self, didChangeActivationState: state)
      }
    }

    /// Notifies observers of reachability change.
    ///
    /// Observers are responsible for thread management.
    /// Use @MainActor on your observer for UI updates.
    internal func notifyReachabilityChanged(_ isReachable: Bool) async {
      await observerRegistry.notify { observer in
        observer.connectivityManager(self, didChangeReachability: isReachable)
      }
    }

    /// Notifies observers of companion app installation status change.
    ///
    /// Observers are responsible for thread management.
    /// Use @MainActor on your observer for UI updates.
    internal func notifyCompanionAppInstalledChanged(_ isInstalled: Bool) async {
      await observerRegistry.notify { observer in
        observer.connectivityManager(self, didChangeCompanionAppInstalled: isInstalled)
      }
    }

    #if os(iOS)
      /// Notifies observers of paired status change (iOS only).
      ///
      /// Observers are responsible for thread management.
      /// Use @MainActor on your observer for UI updates.
      internal func notifyPairedStatusChanged(_ isPaired: Bool) async {
        await observerRegistry.notify { observer in
          observer.connectivityManager(self, didChangePairedStatus: isPaired)
        }
      }
    #endif

    /// Notifies observers of received message.
    ///
    /// Observers are responsible for thread management.
    /// Use @MainActor on your observer for UI updates.
    internal func notifyMessageReceived(_ message: ConnectivityMessage) async {
      await observerRegistry.notify { observer in
        observer.connectivityManager(self, didReceiveMessage: message)
      }
    }

    /// Notifies observers of application context update.
    ///
    /// Observers are responsible for thread management.
    /// Use @MainActor on your observer for UI updates.
    internal func notifyApplicationContextReceived(_ context: ConnectivityMessage) async {
      await observerRegistry.notify { observer in
        observer.connectivityManager(self, didReceiveApplicationContext: context)
      }
    }
  }
#endif
