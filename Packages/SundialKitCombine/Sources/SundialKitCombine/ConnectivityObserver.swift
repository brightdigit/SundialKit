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

#if canImport(Combine)
public import Combine
public import Foundation
public import SundialKitConnectivity
public import SundialKitCore

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
/// // Observe activation completion (with errors)
/// observer.activationCompleted
///   .sink { result in
///     switch result {
///     case .success(let state):
///       print("Activated: \(state)")
///     case .failure(let error):
///       print("Activation failed: \(error)")
///     }
///   }
///   .store(in: &cancellables)
///
/// // Check for activation errors
/// if let error = observer.activationError {
///   print("Last activation error: \(error)")
/// }
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
  @Published public internal(set) var activationState: ActivationState = .notActivated

  /// Whether the counterpart device is reachable
  @Published public internal(set) var isReachable: Bool = false

  /// Whether the companion app is installed (watchOS app on paired iPhone, or iOS app on paired Watch)
  @Published public internal(set) var isPairedAppInstalled: Bool = false

  #if os(iOS)
    /// Whether an Apple Watch is paired (iOS only)
    @Published public internal(set) var isPaired: Bool = false
  #endif

  /// Last activation error (nil if no error occurred)
  @Published public internal(set) var activationError: (any Error)?

  // MARK: - Event Publishers

  /// Publisher for received messages
  public let messageReceived = PassthroughSubject<ConnectivityReceiveResult, Never>()

  /// Publisher for send results
  public let sendResult = PassthroughSubject<ConnectivitySendResult, Never>()

  /// Publisher for activation completion events (with success state or error)
  public let activationCompleted = PassthroughSubject<Result<ActivationState, Error>, Never>()

  /// Publisher for typed decoded messages
  ///
  /// Requires a `MessageDecoder` to be configured during initialization.
  /// Both dictionary and binary messages are automatically decoded into
  /// their typed `Messagable` forms.
  public let typedMessageReceived = PassthroughSubject<Messagable, Never>()

  // MARK: - Private Properties

  private let session: any ConnectivitySession
  internal let messageDecoder: MessageDecoder?

  // MARK: - Initialization

  public init(session: any ConnectivitySession, messageDecoder: MessageDecoder? = nil) {
    self.session = session
    self.messageDecoder = messageDecoder
    session.delegate = self
  }

  #if canImport(WatchConnectivity)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` which uses WatchConnectivity
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    public convenience init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: WatchConnectivitySession(), messageDecoder: messageDecoder)
    }
  #else
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` with a never-available session
    /// - Parameter messageDecoder: Optional decoder for automatic message decoding
    public convenience init(messageDecoder: MessageDecoder? = nil) {
      self.init(session: NeverConnectivitySession(), messageDecoder: messageDecoder)
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
        let sendResult = ConnectivitySendResult(
          message: message, context: .applicationContext(transport: .dictionary)
        )

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

  /// Sends a typed message with automatic transport selection
  ///
  /// Automatically chooses the best transport based on message type:
  /// - `BinaryMessagable` types use binary transport (unless `forceDictionary` option is set)
  /// - `Messagable` types use dictionary transport
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Binary transport (efficient)
  /// let sensor = SensorData(temperature: 72.5)
  /// let result = try await observer.send(sensor)
  ///
  /// // Dictionary transport
  /// let status = StatusMessage(text: "ready")
  /// let result = try await observer.send(status)
  ///
  /// // Force dictionary for testing
  /// let result = try await observer.send(sensor, options: .forceDictionary)
  /// ```
  ///
  /// - Parameters:
  ///   - message: The typed message to send
  ///   - options: Send options (e.g., `.forceDictionary`)
  /// - Returns: The send result with transport indication
  /// - Throws: Error if the message cannot be sent
  public func send(_ message: some Messagable, options: SendOptions = []) async throws
    -> ConnectivitySendResult
  {
    if let binaryMessage = message as? BinaryMessagable, !options.contains(.forceDictionary) {
      // Binary transport

      let data = try BinaryMessageEncoder.encode(binaryMessage)

      if session.isReachable {
        return try await withCheckedThrowingContinuation { continuation in
          session.sendMessageData(data) { result in
            switch result {
            case .success:
              // Note: Binary messages don't have reply data in current WatchConnectivity API
              let sendResult = ConnectivitySendResult(
                message: message.message(),
                context: .reply([:], transport: .binary)
              )
              Task { @MainActor in
                self.sendResult.send(sendResult)
              }
              continuation.resume(returning: sendResult)
            case .failure(let error):
              let sendResult = ConnectivitySendResult(
                message: message.message(),
                context: .failure(error)
              )
              Task { @MainActor in
                self.sendResult.send(sendResult)
              }
              continuation.resume(throwing: error)
            }
          }
        }
      } else {
        // Binary messages require reachability - can't use application context
        let error = SundialError.missingCompanion
        let sendResult = ConnectivitySendResult(
          message: message.message(),
          context: .failure(error)
        )
        self.sendResult.send(sendResult)
        throw error
      }
    } else {
      // Dictionary transport
      return try await sendMessage(message.message())
    }
  }
}
#endif
