//
//  ConnectivityObserver+Lifecycle.swift
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
import SundialKitConnectivity
import SundialKitCore

#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit)
  import AppKit
#endif

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension ConnectivityObserver {
  /// Updates the application context with new data.
  ///
  /// Application context is for background delivery of state updates.
  /// The system will deliver this data to the counterpart device when it's convenient.
  ///
  /// - Parameter context: The context dictionary to send
  /// - Throws: Error if the context cannot be updated
  ///
  /// ## Example
  /// ```swift
  /// let context: [String: any Sendable] = [
  ///   "appVersion": "1.0",
  ///   "lastSync": Date().timeIntervalSince1970
  /// ]
  /// try await observer.updateApplicationContext(context)
  /// ```
  internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
    try session.updateApplicationContext(context)
  }

  /// Sets up automatic observation of app lifecycle to check for pending application context.
  ///
  /// When the app becomes active, this automatically checks if there's a pending
  /// application context that arrived while the app was backgrounded.
  ///
  /// This handles the edge case where:
  /// 1. Session is already activated and reachable
  /// 2. updateApplicationContext arrives while app is backgrounded
  /// 3. App returns to foreground
  /// In this scenario, no activation or reachability events fire, so this is the only
  /// mechanism that will detect and process the pending context.
  internal func setupAppLifecycleObserver() {
    // Guard against multiple calls
    guard appLifecycleTask == nil else {
      return
    }

    appLifecycleTask = Task { [weak self] in
      guard let self else {
        return
      }

      #if canImport(UIKit) && !os(watchOS)
        // iOS/tvOS
        let notificationName = UIApplication.didBecomeActiveNotification
      #elseif os(watchOS)
        // watchOS - use extension-specific notification
        let notificationName = Notification.Name("NSExtensionHostDidBecomeActiveNotification")
      #elseif canImport(AppKit)
        // macOS
        let notificationName = NSApplication.didBecomeActiveNotification
      #else
        // Unsupported platform - return early
        return
      #endif

      #if canImport(Darwin)
        let notifications = NotificationCenter.default.notifications(named: notificationName)

        for await _ in notifications {
          // Check for pending application context when app becomes active
          if let pendingContext = self.session.receivedApplicationContext {
            await self.handleApplicationContext(pendingContext, error: nil)
          }
        }
      #endif
    }
  }
}
