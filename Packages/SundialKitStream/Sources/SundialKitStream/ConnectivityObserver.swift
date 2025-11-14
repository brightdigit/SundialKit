//
//  ConnectivityObserver.swift
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
public import SundialKitConnectivity
public import SundialKitCore

#if canImport(UIKit)
  import UIKit
#endif
#if canImport(AppKit)
  import AppKit
#endif

/// Actor-based WatchConnectivity observer providing AsyncStream APIs
///
/// `ConnectivityObserver` manages communication between iPhone and Apple Watch
/// using Swift concurrency patterns.
///
/// ## Example Usage
///
/// ```swift
/// import SundialKitStream
///
/// let observer = ConnectivityObserver()
/// try await observer.activate()
///
/// // Monitor activation state
/// for await state in observer.activationStates() {
///   print("Activation state: \(state)")
/// }
///
/// // Monitor activation completion (with errors)
/// for await result in observer.activationCompletionStream() {
///   switch result {
///   case .success(let state):
///     print("Activated: \(state)")
///   case .failure(let error):
///     print("Activation failed: \(error)")
///   }
/// }
///
/// // Check for activation errors
/// if let error = await observer.getCurrentActivationError() {
///   print("Last activation error: \(error)")
/// }
///
/// // Send messages
/// let result = try await observer.sendMessage(["key": "value"])
/// ```
///
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public actor ConnectivityObserver: ConnectivitySessionDelegate, StateHandling, MessageHandling {
  // MARK: - Private Properties

  internal let session: any ConnectivitySession
  internal let messageRouter: MessageRouter
  internal let continuationManager: StreamContinuationManager

  /// Manages connectivity activation state and stream continuations
  public let stateManager: ConnectivityStateManager

  /// Handles distribution of incoming messages to stream subscribers
  public let messageDistributor: MessageDistributor

  private var appLifecycleTask: Task<Void, Never>?

  // MARK: - Initialization

  internal init(session: any ConnectivitySession, messageDecoder: MessageDecoder? = nil) {
    self.session = session
    self.messageRouter = MessageRouter(session: session)
    self.continuationManager = StreamContinuationManager()
    self.stateManager = ConnectivityStateManager(continuationManager: continuationManager)
    self.messageDistributor = MessageDistributor(
      continuationManager: continuationManager,
      messageDecoder: messageDecoder
    )

    // Ensure session doesn't already have a delegate
    assert(
      session.delegate == nil,
      "Session already has a delegate - multiple delegates will cause undefined behavior"
    )
    session.delegate = self
  }

  deinit {
    appLifecycleTask?.cancel()
  }

  #if canImport(WatchConnectivity)
    /// Creates a `ConnectivityObserver` which uses WatchConnectivity
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: WatchConnectivitySession(), messageDecoder: messageDecoder)
    }
  #else
    /// Creates a `ConnectivityObserver` with a never-available session
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: NeverConnectivitySession(), messageDecoder: messageDecoder)
    }
  #endif

  // MARK: - Public API

  /// Activates the connectivity session
  /// - Throws: `ConnectivityError.sessionNotSupported` if not supported
  public func activate() throws {
    try session.activate()
    setupAppLifecycleObserver()
  }

  /// Checks for pending application context that may have arrived while the app was inactive.
  ///
  /// This method is provided for manual checking, but is **automatically called** in the
  /// following scenarios:
  /// - After successful session activation
  /// - When the session becomes reachable
  /// - When the app returns to the foreground (via app lifecycle notifications)
  ///
  /// Most apps will not need to call this method directly.
  public func checkPendingApplicationContext() async {
    if let pendingContext = session.receivedApplicationContext {
      await handleApplicationContext(pendingContext, error: nil)
    }
  }

  /// Gets the current activation state snapshot
  /// - Returns: The current activation state, or nil if not yet activated
  public func getCurrentActivationState() async -> ActivationState? {
    await stateManager.activationState
  }

  /// Gets the last activation error
  /// - Returns: The last activation error, or nil if no error occurred
  public func getCurrentActivationError() async -> (any Error)? {
    await stateManager.activationError
  }

  /// Gets the current reachability status
  /// - Returns: Whether the counterpart is reachable
  public func isReachable() async -> Bool {
    await stateManager.isReachable
  }

  /// Gets the current paired app installed status
  /// - Returns: Whether the companion app is installed
  public func isPairedAppInstalled() async -> Bool {
    await stateManager.isPairedAppInstalled
  }

  #if os(iOS)
    /// Gets the current paired status (iOS only)
    /// - Returns: Whether an Apple Watch is paired
    @available(watchOS, unavailable)
    public func isPaired() async -> Bool {
      await stateManager.isPaired
    }
  #endif

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
  public func updateApplicationContext(_ context: ConnectivityMessage) throws {
    try session.updateApplicationContext(context)
  }

  // MARK: - Private Helpers

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
  private func setupAppLifecycleObserver() {
    // Guard against multiple calls
    guard appLifecycleTask == nil else { return }

    appLifecycleTask = Task { [weak self] in
      guard let self else { return }

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
