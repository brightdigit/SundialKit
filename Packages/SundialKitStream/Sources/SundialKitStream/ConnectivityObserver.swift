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
public actor ConnectivityObserver: ConnectivitySessionDelegate {
  // MARK: - Private Properties

  internal let session: any ConnectivitySession
  private let messageRouter: MessageRouter
  private let messageDecoder: MessageDecoder?

  // Current state
  private var state: ConnectivityState = .initial

  // Stream continuations for active subscribers
  private var activationContinuations: [UUID: AsyncStream<ActivationState>.Continuation] = [:]
  private var activationCompletionContinuations:
    [UUID: AsyncStream<Result<ActivationState, any Error>>.Continuation] = [:]
  private var reachabilityContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var pairedAppInstalledContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var pairedContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var messageReceivedContinuations:
    [UUID: AsyncStream<ConnectivityReceiveResult>.Continuation] = [:]
  private var typedMessageContinuations: [UUID: AsyncStream<any Messagable>.Continuation] = [:]
  private var sendResultContinuations: [UUID: AsyncStream<ConnectivitySendResult>.Continuation] =
    [:]

  // MARK: - Initialization

  internal init(session: any ConnectivitySession, messageDecoder: MessageDecoder? = nil) {
    self.session = session
    self.messageRouter = MessageRouter(session: session)
    self.messageDecoder = messageDecoder
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
  public func getCurrentActivationState() -> ActivationState? {
    state.activationState
  }

  /// Gets the last activation error
  /// - Returns: The last activation error, or nil if no error occurred
  public func getCurrentActivationError() -> (any Error)? {
    state.activationError
  }

  /// Gets the current reachability status
  /// - Returns: Whether the counterpart is reachable
  public func isReachable() -> Bool {
    state.isReachable
  }

  /// Gets the current paired app installed status
  /// - Returns: Whether the companion app is installed
  public func isPairedAppInstalled() -> Bool {
    state.isPairedAppInstalled
  }

  #if os(iOS)
    /// Gets the current paired status (iOS only)
    /// - Returns: Whether an Apple Watch is paired
    @available(watchOS, unavailable)
    public func isPaired() -> Bool {
      state.isPaired
    }
  #endif

  // MARK: - AsyncStream APIs

  /// AsyncStream of activation state changes
  /// - Returns: Stream that yields activation states as they change
  public func activationStates() -> AsyncStream<ActivationState> {
    AsyncStream { continuation in
      let id = UUID()
      activationContinuations[id] = continuation

      // Send current value immediately if available
      if let currentActivationState = state.activationState {
        continuation.yield(currentActivationState)
      }

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeActivationContinuation(id: id) }
      }
    }
  }

  /// AsyncStream of activation completion events (with success state or error)
  /// - Returns: Stream that yields Result containing activation state or error
  public func activationCompletionStream() -> AsyncStream<Result<ActivationState, Error>> {
    AsyncStream { continuation in
      let id = UUID()
      activationCompletionContinuations[id] = continuation

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeActivationCompletionContinuation(id: id) }
      }
    }
  }

  /// AsyncStream of reachability changes
  /// - Returns: Stream that yields reachability status as it changes
  public func reachabilityUpdates() -> AsyncStream<Bool> {
    AsyncStream { continuation in
      let id = UUID()
      reachabilityContinuations[id] = continuation

      // Send current value immediately
      continuation.yield(state.isReachable)

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeReachabilityContinuation(id: id) }
      }
    }
  }

  /// AsyncStream of paired app installed status changes
  /// - Returns: Stream that yields paired app installed status as it changes
  public func pairedAppInstalledUpdates() -> AsyncStream<Bool> {
    AsyncStream { continuation in
      let id = UUID()
      pairedAppInstalledContinuations[id] = continuation

      // Send current value immediately
      continuation.yield(state.isPairedAppInstalled)

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removePairedAppInstalledContinuation(id: id) }
      }
    }
  }

  #if os(iOS)
    /// AsyncStream of paired status changes (iOS only)
    /// - Returns: Stream that yields paired status as it changes
    @available(watchOS, unavailable)
    public func pairedUpdates() -> AsyncStream<Bool> {
      AsyncStream { continuation in
        let id = UUID()
        pairedContinuations[id] = continuation

        // Send current value immediately
        continuation.yield(currentIsPaired)

        continuation.onTermination = { [weak self] _ in
          Task { await self?.removePairedContinuation(id: id) }
        }
      }
    }
  #endif

  /// AsyncStream of received messages
  /// - Returns: Stream that yields messages as they are received
  public func messageStream() -> AsyncStream<ConnectivityReceiveResult> {
    AsyncStream { continuation in
      let id = UUID()
      messageReceivedContinuations[id] = continuation

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeMessageReceivedContinuation(id: id) }
      }
    }
  }

  /// AsyncStream of typed decoded messages
  ///
  /// Requires a `MessageDecoder` to be configured during initialization.
  /// Both dictionary and binary messages are automatically decoded into
  /// their typed `Messagable` forms.
  ///
  /// - Returns: Stream that yields decoded messages as they are received
  public func typedMessageStream() -> AsyncStream<Messagable> {
    AsyncStream { continuation in
      let id = UUID()
      typedMessageContinuations[id] = continuation

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeTypedMessageContinuation(id: id) }
      }
    }
  }

  /// AsyncStream of send results
  /// - Returns: Stream that yields send results as messages are sent
  public func sendResultStream() -> AsyncStream<ConnectivitySendResult> {
    AsyncStream { continuation in
      let id = UUID()
      sendResultContinuations[id] = continuation

      continuation.onTermination = { [weak self] _ in
        Task { await self?.removeSendResultContinuation(id: id) }
      }
    }
  }

  // MARK: - Message Sending

  /// Sends a message to the counterpart device
  /// - Parameter message: The message to send (must be property list types)
  /// - Returns: The send result
  /// - Throws: Error if the message cannot be sent
  public func sendMessage(_ message: ConnectivityMessage) async throws -> ConnectivitySendResult {
    do {
      let sendResult = try await messageRouter.send(message)

      // Notify send result stream subscribers
      for continuation in sendResultContinuations.values {
        continuation.yield(sendResult)
      }

      return sendResult
    } catch {
      let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

      // Notify send result stream subscribers
      for continuation in sendResultContinuations.values {
        continuation.yield(sendResult)
      }

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
    // Determine transport based on type and options
    if let binaryMessage = message as? BinaryMessagable,
      !options.contains(.forceDictionary)
    {
      // Binary transport
      let data = try BinaryMessageEncoder.encode(binaryMessage)
      let originalMessage = message.message()

      do {
        let sendResult = try await messageRouter.sendBinary(data, originalMessage: originalMessage)

        // Notify send result stream subscribers
        for continuation in sendResultContinuations.values {
          continuation.yield(sendResult)
        }

        return sendResult
      } catch {
        let sendResult = ConnectivitySendResult(
          message: originalMessage,
          context: .failure(error)
        )

        // Notify send result stream subscribers
        for continuation in sendResultContinuations.values {
          continuation.yield(sendResult)
        }

        throw error
      }
    } else {
      // Dictionary transport
      return try await sendMessage(message.message())
    }
  }

  // MARK: - ConnectivitySessionDelegate (nonisolated to receive callbacks)

  nonisolated public func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith state: ActivationState,
    error: Error?
  ) {
    Task { await handleActivation(state, error: error) }
  }

  nonisolated public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
    Task { await handleActivation(session.activationState, error: nil) }
  }

  nonisolated public func sessionDidDeactivate(_ session: any ConnectivitySession) {
    Task { await handleActivation(session.activationState, error: nil) }
  }

  nonisolated public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
    Task { await handleReachabilityChange(session.isReachable) }
  }

  nonisolated public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
    Task { await handleCompanionStateChange(session) }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) {
    Task {
      await handleMessage(message, replyHandler: replyHandler)
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: Error?
  ) {
    Task {
      await handleApplicationContext(applicationContext, error: error)
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  ) {
    Task {
      await handleBinaryMessage(messageData, replyHandler: replyHandler)
    }
  }

  // MARK: - Internal Handlers

  private func handleActivation(_ activationState: ActivationState, error: Error?) {
    #if os(iOS)
      self.state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: session.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: session.isPaired
      )
    #else
      self.state = ConnectivityState(
        activationState: activationState,
        activationError: error,
        isReachable: session.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: false
      )
    #endif

    // Notify all activation state subscribers
    for continuation in activationContinuations.values {
      continuation.yield(activationState)
    }

    // Notify activation completion subscribers with Result
    let result: Result<ActivationState, Error> =
      if let error = error {
        .failure(error)
      } else {
        .success(activationState)
      }
    for continuation in activationCompletionContinuations.values {
      continuation.yield(result)
    }

    for continuation in reachabilityContinuations.values {
      continuation.yield(state.isReachable)
    }

    for continuation in pairedAppInstalledContinuations.values {
      continuation.yield(state.isPairedAppInstalled)
    }

    #if os(iOS)
      for continuation in pairedContinuations.values {
        continuation.yield(state.isPaired)
      }
    #endif
  }

  private func handleReachabilityChange(_ isReachable: Bool) {
    #if os(iOS)
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: state.isPaired
      )
    #else
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: isReachable,
        isPairedAppInstalled: state.isPairedAppInstalled,
        isPaired: false
      )
    #endif

    for continuation in reachabilityContinuations.values {
      continuation.yield(isReachable)
    }
  }

  private func handleCompanionStateChange(_ session: any ConnectivitySession) {
    #if os(iOS)
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: state.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: session.isPaired
      )
    #else
      state = ConnectivityState(
        activationState: state.activationState,
        activationError: state.activationError,
        isReachable: state.isReachable,
        isPairedAppInstalled: session.isPairedAppInstalled,
        isPaired: false
      )
    #endif

    for continuation in pairedAppInstalledContinuations.values {
      continuation.yield(state.isPairedAppInstalled)
    }

    #if os(iOS)
      for continuation in pairedContinuations.values {
        continuation.yield(state.isPaired)
      }
    #endif
  }

  private func handleMessage(
    _ message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) {
    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(message: message, context: .replyWith(replyHandler))
    for continuation in messageReceivedContinuations.values {
      continuation.yield(result)
    }

    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(message)
        for continuation in typedMessageContinuations.values {
          continuation.yield(decoded)
        }
      } catch {
        // Decoding failed - log but don't crash (raw stream still gets the message)
        print("Failed to decode message: \(error)")
      }
    }
  }

  private func handleApplicationContext(_ applicationContext: ConnectivityMessage, error: Error?) {
    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(
      message: applicationContext, context: .applicationContext
    )
    for continuation in messageReceivedContinuations.values {
      continuation.yield(result)
    }

    // Decode and send to typed stream subscribers if no error
    if error == nil, let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(applicationContext)
        for continuation in typedMessageContinuations.values {
          continuation.yield(decoded)
        }
      } catch {
        // Decoding failed - log but don't crash (raw stream still gets the message)
        print("Failed to decode application context: \(error)")
      }
    }
  }

  private func handleBinaryMessage(_ data: Data, replyHandler: @escaping @Sendable (Data) -> Void) {
    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decodeBinary(data)
        for continuation in typedMessageContinuations.values {
          continuation.yield(decoded)
        }
      } catch {
        // Decoding failed - log the error
        print("Failed to decode binary message: \(error)")
      }
    }
  }

  private func notifySendResult(_ result: ConnectivitySendResult) {
    for continuation in sendResultContinuations.values {
      continuation.yield(result)
    }
  }

  // MARK: - Continuation Management

  private func removeActivationContinuation(id: UUID) {
    activationContinuations.removeValue(forKey: id)
  }

  private func removeActivationCompletionContinuation(id: UUID) {
    activationCompletionContinuations.removeValue(forKey: id)
  }

  private func removeReachabilityContinuation(id: UUID) {
    reachabilityContinuations.removeValue(forKey: id)
  }

  private func removePairedAppInstalledContinuation(id: UUID) {
    pairedAppInstalledContinuations.removeValue(forKey: id)
  }

  private func removePairedContinuation(id: UUID) {
    pairedContinuations.removeValue(forKey: id)
  }

  private func removeMessageReceivedContinuation(id: UUID) {
    messageReceivedContinuations.removeValue(forKey: id)
  }

  private func removeTypedMessageContinuation(id: UUID) {
    typedMessageContinuations.removeValue(forKey: id)
  }

  private func removeSendResultContinuation(id: UUID) {
    sendResultContinuations.removeValue(forKey: id)
  }
}
