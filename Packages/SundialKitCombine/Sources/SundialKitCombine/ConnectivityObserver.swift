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
    public let activationCompleted = PassthroughSubject<Result<ActivationState, any Error>, Never>()

    /// Publisher for typed decoded messages
    ///
    /// Requires a `MessageDecoder` to be configured during initialization.
    /// Both dictionary and binary messages are automatically decoded into
    /// their typed `Messagable` forms.
    public let typedMessageReceived = PassthroughSubject<any Messagable, Never>()

    // MARK: - Private Properties

    internal let session: any ConnectivitySession
    internal let messageDecoder: MessageDecoder?

    // MARK: - Initialization

    /// Creates a new connectivity observer with the specified session and message decoder.
    ///
    /// - Parameters:
    ///   - session: The connectivity session to observe
    ///   - messageDecoder: Optional message decoder for typed message handling
    public init(session: any ConnectivitySession, messageDecoder: MessageDecoder? = nil) {
      self.session = session
      self.messageDecoder = messageDecoder
      session.delegate = self
    }
  }
#endif
