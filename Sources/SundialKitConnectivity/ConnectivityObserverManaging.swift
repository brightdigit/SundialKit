//
//  ConnectivityObserverManaging.swift
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
    func addObserver(_ observer: any ConnectivityStateObserver)

    /// Removes a specific observer.
    ///
    /// - Parameter observer: The observer to remove.
    func removeObserver(_ observer: any ConnectivityStateObserver)

    /// Removes observers matching the predicate.
    ///
    /// - Parameter predicate: Closure to identify observers to remove.
    func removeObservers(
      where predicate: @Sendable @escaping (any ConnectivityStateObserver) -> Bool)
  }

  // MARK: - Default Implementation

  extension ConnectivityObserverManaging {
    /// Default implementation for removing a specific observer.
    ///
    /// Uses identity comparison to match observers.
    ///
    /// - Parameter observer: The observer to remove.
    public func removeObserver(_ observer: any ConnectivityStateObserver) {
      removeObservers { storedObserver in
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
    /// Notifies observers of activation state change on main queue.
    internal func notifyActivationStateChanged(_ state: ActivationState) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }
        observerRegistry.notify { observer in
          observer.connectivityManager(self, didChangeActivationState: state)
        }
      }
    }

    /// Notifies observers of reachability change on main queue.
    internal func notifyReachabilityChanged(_ isReachable: Bool) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }
        observerRegistry.notify { observer in
          observer.connectivityManager(self, didChangeReachability: isReachable)
        }
      }
    }

    /// Notifies observers of companion app installation status change on main queue.
    internal func notifyCompanionAppInstalledChanged(_ isInstalled: Bool) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }
        observerRegistry.notify { observer in
          observer.connectivityManager(self, didChangeCompanionAppInstalled: isInstalled)
        }
      }
    }

    #if os(iOS)
      /// Notifies observers of paired status change on main queue (iOS only).
      internal func notifyPairedStatusChanged(_ isPaired: Bool) {
        DispatchQueue.main.async { [weak self] in
          guard let self = self else {
            return
          }
          observerRegistry.notify { observer in
            observer.connectivityManager(self, didChangePairedStatus: isPaired)
          }
        }
      }
    #endif

    /// Notifies observers of received message on main queue.
    internal func notifyMessageReceived(_ message: ConnectivityMessage) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }
        observerRegistry.notify { observer in
          observer.connectivityManager(self, didReceiveMessage: message)
        }
      }
    }

    /// Notifies observers of application context update on main queue.
    internal func notifyApplicationContextReceived(_ context: ConnectivityMessage) {
      DispatchQueue.main.async { [weak self] in
        guard let self = self else {
          return
        }
        observerRegistry.notify { observer in
          observer.connectivityManager(self, didReceiveApplicationContext: context)
        }
      }
    }
  }
#endif
