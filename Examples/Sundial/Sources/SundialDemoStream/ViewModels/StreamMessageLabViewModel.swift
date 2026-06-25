//
//  StreamMessageLabViewModel.swift
//  Sundial
//
//  Created on 11/1/25.
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

import Foundation
import Observation
import os.log
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

/// ViewModel for Message Transport Lab using SundialKitStream.
///
/// Uses @Observable (iOS 17+) with actor-based ConnectivityObserver and AsyncStream APIs.
/// Demonstrates modern Swift concurrency patterns with strict concurrency compliance.
///
/// Features:
/// - AsyncStream consumption for reactive state updates
/// - Actor-isolated ConnectivityObserver
/// - Binary protobuf encoding with different transport methods
/// - Swift 6.1 strict concurrency compliant
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
@Observable
@MainActor
internal final class StreamMessageLabViewModel {
  // MARK: - Published State

  /// Currently selected color for sending
  internal var selectedColor: Color = .blue

  /// Payload complexity (0 = simple ColorMessage, 1 = ComplexMessage)
  internal var complexityLevel: Double = 0

  /// Manual transport method override (nil = automatic)
  internal var selectedTransportMethod: TransportMethod?

  /// Last color sent
  internal var lastSentColor: ColorWithMetadata?

  /// Last color received
  internal var lastReceivedColor: ColorWithMetadata?

  /// Whether a send operation is in progress
  internal var isSending: Bool = false

  /// Last send error message
  internal var lastError: String?

  /// Message send statistics
  internal var messagesSent: Int = 0
  internal var messagesReceived: Int = 0

  /// Current reachability status
  internal var isReachable: Bool = false

  /// Current activation state
  internal var activationState: ActivationState = .notActivated

  /// Whether devices are paired (iOS only, always true on watchOS)
  internal var isPaired: Bool = {
    #if os(watchOS)
      return true
    #else
      return false
    #endif
  }()

  /// Whether companion app is installed
  internal var isPairedAppInstalled: Bool = false

  // MARK: - Dependencies

  /// Actor-based connectivity observer
  internal let connectivityObserver: ConnectivityObserver

  /// Task for consuming streams
  nonisolated(unsafe) private var streamTask: Task<Void, Never>?

  // MARK: - Computed Properties

  /// Automatically selected transport method based on reachability
  internal var automaticTransportMethod: TransportMethod {
    isReachable ? .sendMessage : .updateApplicationContext
  }

  /// Effective transport method (manual override or automatic)
  internal var effectiveTransportMethod: TransportMethod {
    selectedTransportMethod ?? automaticTransportMethod
  }

  // MARK: - Initialization

  internal init(connectivityObserver: ConnectivityObserver? = nil) {
    #if os(iOS) || os(watchOS)
      self.connectivityObserver =
        connectivityObserver
        ?? ConnectivityObserver(
          messageDecoder: MessageDecoder(messagableTypes: [
            Sundial_Demo_ColorMessage.self,
            Sundial_Demo_ComplexMessage.self,
          ])
        )
    #else
      // ConnectivityObserver has no public initializer on macOS/tvOS, so an
      // explicit observer must be supplied by the caller on those platforms.
      guard let connectivityObserver else {
        fatalError(
          "ConnectivityObserver must be explicitly provided on macOS. Create it with: "
            + "ConnectivityObserver(session: NeverConnectivitySession(), messageDecoder: ...)"
        )
      }
      self.connectivityObserver = connectivityObserver
    #endif
    setupStreams()
  }

  // MARK: - Setup

  private func setupStreams() {
    streamTask = Task { @MainActor in
      await activateAndLogInitialState()
      await consumeAllStreams()
    }
  }

  private func activateAndLogInitialState() async {
    do {
      try await connectivityObserver.activate()
      logIfAvailable { DemoLogger.shared.info("ConnectivityObserver activated successfully") }
      Task { @MainActor in
        try? await Task.sleep(for: .milliseconds(500))
        await logInitialState()
      }
    } catch {
      lastError = "Failed to activate: \(error.localizedDescription)"
      logIfAvailable {
        DemoLogger.shared.error("ConnectivityObserver activation failed: \(error)")
      }
    }
  }

  private func consumeAllStreams() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.consumeTypedMessages() }
      group.addTask { await self.consumeReachability() }
      group.addTask { await self.consumeActivationState() }
      #if os(iOS)
        group.addTask { await self.consumePairedStatus() }
      #endif
      group.addTask { await self.consumePairedAppInstalledStatus() }
    }
  }

  /// Runs `body` only on OS versions where `DemoLogger` is available.
  internal func logIfAvailable(_ body: () -> Void) {
    if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
      body()
    }
  }

  deinit {
    streamTask?.cancel()
  }
}
