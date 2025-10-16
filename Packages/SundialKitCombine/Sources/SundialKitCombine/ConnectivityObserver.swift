//
//  ConnectivityObserver.swift
//  SundialKitCombine
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

public import Combine
public import Foundation
public import SundialKitCore
public import SundialKitConnectivity

/// MainActor-isolated WatchConnectivity observer providing Combine publishers
///
/// `ConnectivityObserver` manages communication between iPhone and Apple Watch
/// using Combine reactive patterns. All state updates occur on the main thread.
///
/// ## Example Usage
///
/// ```swift
/// import SundialKitCombine
///
/// let observer = ConnectivityObserver()
/// try observer.activate()
///
/// // Observe activation state
/// observer.$activationState
///   .sink { state in
///     print("Activation state: \(state)")
///   }
///   .store(in: &cancellables)
///
/// // Observe messages
/// observer.messageReceived
///   .sink { result in
///     print("Received: \(result.message)")
///   }
///   .store(in: &cancellables)
///
/// // Send messages
/// Task {
///   let result = try await observer.sendMessage(["key": "value"])
///   print("Sent successfully: \(result)")
/// }
/// ```
///
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
@MainActor
public final class ConnectivityObserver: ConnectivitySessionDelegate {

  // MARK: - Published Properties

  /// Current activation state
  @Published public private(set) var activationState: ActivationState = .notActivated

  /// Whether the counterpart device is reachable
  @Published public private(set) var isReachable: Bool = false

  /// Whether the companion app is installed (watchOS app on paired iPhone, or iOS app on paired Watch)
  @Published public private(set) var isPairedAppInstalled: Bool = false

  #if os(iOS)
    /// Whether an Apple Watch is paired (iOS only)
    @Published public private(set) var isPaired: Bool = false
  #endif

  // MARK: - Event Publishers

  /// Publisher for received messages
  public let messageReceived = PassthroughSubject<ConnectivityReceiveResult, Never>()

  /// Publisher for send results
  public let sendResult = PassthroughSubject<ConnectivitySendResult, Never>()

  // MARK: - Private Properties

  private let session: any ConnectivitySession

  // MARK: - Initialization

  public init(session: any ConnectivitySession) {
    self.session = session
    session.delegate = self
  }

  #if canImport(WatchConnectivity)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` which uses WatchConnectivity
    public convenience init() {
      self.init(session: WatchConnectivitySession())
    }
  #else
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` with a never-available session
    public convenience init() {
      self.init(session: NeverConnectivitySession())
    }
  #endif

  // MARK: - Public API

  /// Activates the connectivity session
  /// - Throws: `ConnectivityError.sessionNotSupported` if not supported
  public func activate() throws {
    try session.activate()
  }

  /// Sends a message to the counterpart device
  /// - Parameter message: The message to send (must be property list types)
  /// - Returns: The send result
  /// - Throws: Error if the message cannot be sent
  public func sendMessage(_ message: ConnectivityMessage) async throws -> ConnectivitySendResult {
    if session.isReachable {
      // Use sendMessage for immediate delivery when reachable
      return try await withCheckedThrowingContinuation { continuation in
        session.sendMessage(message) { result in
          let sendResult = ConnectivitySendResult(message: message, context: .init(result))

          // Notify subscribers on main thread
          Task { @MainActor in
            self.sendResult.send(sendResult)
          }

          continuation.resume(returning: sendResult)
        }
      }
    } else if session.isPairedAppInstalled {
      // Use application context for background delivery
      do {
        try session.updateApplicationContext(message)
        let sendResult = ConnectivitySendResult(message: message, context: .applicationContext)

        // Notify subscribers
        self.sendResult.send(sendResult)

        return sendResult
      } catch {
        let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

        // Notify subscribers
        self.sendResult.send(sendResult)

        throw error
      }
    } else {
      // No way to deliver the message
      let error = SundialError.missingCompanion
      let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

      // Notify subscribers
      self.sendResult.send(sendResult)

      throw error
    }
  }

  // MARK: - ConnectivitySessionDelegate

  nonisolated public func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith state: ActivationState,
    error: (any Error)?
  ) {
    Task { @MainActor in
      self.activationState = state
      self.isReachable = session.isReachable
      self.isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        self.isPaired = session.isPaired
      #endif
    }
  }

  nonisolated public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
    Task { @MainActor in
      self.activationState = session.activationState
    }
  }

  nonisolated public func sessionDidDeactivate(_ session: any ConnectivitySession) {
    Task { @MainActor in
      self.activationState = session.activationState
    }
  }

  nonisolated public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
    Task { @MainActor in
      self.isReachable = session.isReachable
    }
  }

  nonisolated public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
    Task { @MainActor in
      self.isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        self.isPaired = session.isPaired
      #endif
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) {
    Task { @MainActor in
      let result = ConnectivityReceiveResult(message: message, context: .replyWith(replyHandler))
      self.messageReceived.send(result)
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: (any Error)?
  ) {
    Task { @MainActor in
      let result = ConnectivityReceiveResult(message: applicationContext, context: .applicationContext)
      self.messageReceived.send(result)
    }
  }
}
