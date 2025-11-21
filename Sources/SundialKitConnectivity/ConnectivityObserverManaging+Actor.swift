//
//  ConnectivityObserverManaging+Actor.swift
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
