//
//  MessageLabViewModel.swift
//  Sundial
//
//  Created on 10/27/25.
//  Copyright (c) 2025 BrightDigit.
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

import Combine
import Foundation
import os.log
import SundialDemoShared
import SundialKitCombine
import SundialKitConnectivity
import SundialKitCore
import SwiftUI

/// ViewModel for Message Transport Lab (Tab 1).
///
/// Manages message sending via WatchConnectivity using SundialKitCombine's
/// @MainActor-based ConnectivityObserver. Demonstrates binary protobuf encoding
/// with different transport methods.
///
/// Features:
/// - Payload complexity adjustment (simple color vs complex nested messages)
/// - Manual transport method selection
/// - Sent/received color tracking
/// - Real-time connection status
@available(iOS 16.0, watchOS 9.0, *)
@MainActor
internal final class MessageLabViewModel: ObservableObject {
  // MARK: - Published State

  /// Currently selected color for sending
  @Published internal var selectedColor: Color = .blue

  /// Payload complexity (0 = simple ColorMessage, 1 = ComplexMessage)
  @Published internal var complexityLevel: Double = 0

  /// Manual transport method override (nil = automatic)
  @Published internal var selectedTransportMethod: TransportMethod?

  /// Last color sent
  @Published internal var lastSentColor: ColorWithMetadata?

  /// Last color received
  @Published internal var lastReceivedColor: ColorWithMetadata?

  /// Whether a send operation is in progress
  @Published internal var isSending: Bool = false

  /// Last send error message
  @Published internal var lastError: String?

  /// Message send statistics
  @Published internal var messagesSent: Int = 0
  @Published internal var messagesReceived: Int = 0

  // MARK: - Dependencies

  /// Connectivity observer for WatchConnectivity
  private let connectivityObserver: ConnectivityObserver

  /// Cancellable subscriptions
  private var cancellables = Set<AnyCancellable>()

  // MARK: - Computed Properties

  /// Whether the counterpart is reachable for sendMessage
  internal var isReachable: Bool {
    connectivityObserver.isReachable
  }

  /// Current activation state
  internal var activationState: String {
    // ConnectivityObserver should expose this - placeholder for now
    "Activated"
  }

  /// Automatically selected transport method based on reachability
  internal var automaticTransportMethod: TransportMethod {
    isReachable ? .sendMessage : .updateApplicationContext
  }

  /// Effective transport method (manual override or automatic)
  internal var effectiveTransportMethod: TransportMethod {
    selectedTransportMethod ?? automaticTransportMethod
  }

  // MARK: - Initialization

  #if os(iOS) || os(watchOS)
    internal init(
      connectivityObserver: ConnectivityObserver = .init(
        messageDecoder: MessageDecoder(messagableTypes: [
          Sundial_Demo_ColorMessage.self,
          Sundial_Demo_ComplexMessage.self
        ])
      )
    ) {
      self.connectivityObserver = connectivityObserver

      // Activate connectivity session (synchronous on @MainActor)
      do {
        try connectivityObserver.activate()
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("ConnectivityObserver activated successfully")
        }
      } catch {
        lastError = "Failed to activate: \(error.localizedDescription)"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.error("ConnectivityObserver activation failed: \(error)")
        }
      }

      setupSubscriptions()
    }
  #else
    internal init(
      connectivityObserver: ConnectivityObserver = .init(
        session: NeverConnectivitySession()
      )
    ) {
      self.connectivityObserver = connectivityObserver

      // Activate connectivity session (synchronous on @MainActor)
      do {
        try connectivityObserver.activate()
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.info("ConnectivityObserver activated successfully")
        }
      } catch {
        lastError = "Failed to activate: \(error.localizedDescription)"
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
          DemoLogger.shared.error("ConnectivityObserver activation failed: \(error)")
        }
      }

      setupSubscriptions()
    }
  #endif

  // MARK: - Setup

  private func setupSubscriptions() {
    // Subscribe to typed binary messages (decoded protobuf messages)
    connectivityObserver.typedMessageReceived
      .sink { [weak self] message in
        self?.logDebug("Received typed message: \(type(of: message))")
        self?.handleReceivedTypedMessage(message)
      }
      .store(in: &cancellables)

    // Subscribe to reachability changes
    connectivityObserver.$isReachable
      .sink { [weak self] isReachable in
        self?.logReachabilityChange(isReachable)
      }
      .store(in: &cancellables)

    // Subscribe to activation state changes
    connectivityObserver.$activationState
      .sink { [weak self] state in
        self?.logInfo("Activation state changed: \(String(describing: state))")
      }
      .store(in: &cancellables)
  }

  private func logReachabilityChange(_ isReachable: Bool) {
    logInfo("Reachability changed: \(isReachable)")
    logDebug("isPairedAppInstalled: \(connectivityObserver.isPairedAppInstalled)")
    logDebug("activationState: \(String(describing: connectivityObserver.activationState))")
  }

  // MARK: - Actions

  /// Send the currently selected color using effective transport method.
  internal func sendColor() async {
    guard !isSending else {
      logDebug("Already sending, skipping")
      return
    }

    logDebug("Starting send operation...")
    isSending = true
    defer {
      isSending = false
      logDebug("Send operation complete, isSending reset to false")
    }

    lastError = nil

    do {
      let message = try buildMessage()
      logDebug("Message built successfully, type: \(type(of: message))")
      let result = try await connectivityObserver.send(message)
      handleSendSuccess(context: result.context)
    } catch {
      handleSendFailure(error)
    }
  }
}
