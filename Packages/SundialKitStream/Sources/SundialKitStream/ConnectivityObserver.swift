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
  internal let stateManager: ConnectivityStateManager
  internal let messageDistributor: MessageDistributor

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
    session.delegate = self
  }

  #if canImport(WatchConnectivity)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` which uses WatchConnectivity
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    public init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: WatchConnectivitySession(), messageDecoder: messageDecoder)
    }
  #else
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` with a never-available session
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    public init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: NeverConnectivitySession(), messageDecoder: messageDecoder)
    }
  #endif

  // MARK: - Public API

  /// Activates the connectivity session
  /// - Throws: `ConnectivityError.sessionNotSupported` if not supported
  public func activate() throws {
    try session.activate()
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
}
