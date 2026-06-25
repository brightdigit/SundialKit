//
//  StreamMessageLabViewModel+Actions.swift
//  Sundial
//
//  Copyright (c) 2025 BrightDigit.
//

import Foundation
import os.log
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
extension StreamMessageLabViewModel {
  /// Send the currently selected color using effective transport method.
  internal func sendColor() async {
    guard !isSending else {
      logIfAvailable { DemoLogger.shared.debug("Already sending, skipping") }
      return
    }

    logIfAvailable { DemoLogger.shared.debug("Starting send operation...") }
    isSending = true
    defer {
      isSending = false
      logIfAvailable {
        DemoLogger.shared.debug("Send operation complete, isSending reset to false")
      }
    }

    lastError = nil

    do {
      let message = try buildMessage()
      logIfAvailable {
        DemoLogger.shared.debug(
          "Message built, type: \(String(describing: type(of: message)))"
        )
      }
      await logLiveState()
      try await route(message)
    } catch {
      lastError = error.localizedDescription
      logIfAvailable {
        DemoLogger.shared.error("Send error: \(error)")
        DemoLogger.shared.error("Error description: \(error.localizedDescription)")
      }
    }
  }

  /// Generate a random color.
  internal func randomizeColor() {
    selectedColor = Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }

  // MARK: - Send Routing

  /// Routes a built message to the effective transport method and records success.
  private func route(_ message: any BinaryMessagable) async throws {
    logIfAvailable {
      DemoLogger.shared.debug(
        "Sending message via \(String(describing: self.effectiveTransportMethod))..."
      )
    }

    switch effectiveTransportMethod {
    case .updateApplicationContext:
      try await sendViaApplicationContext(message)
    case .sendMessage, .sendMessageData:
      try await sendViaInteractiveMessage(message)
    }
  }

  private func sendViaApplicationContext(_ message: any BinaryMessagable) async throws {
    logIfAvailable {
      DemoLogger.shared.debug("Converting message to application context...")
    }
    let context = message.message()
    try await connectivityObserver.updateApplicationContext(context)
    logIfAvailable {
      DemoLogger.shared.info("Message sent successfully via updateApplicationContext")
    }
    recordSentColor()
  }

  private func sendViaInteractiveMessage(_ message: any BinaryMessagable) async throws {
    let result = try await connectivityObserver.send(message)
    logIfAvailable {
      DemoLogger.shared.info(
        "Message sent successfully via: \(String(describing: result.context))"
      )
      if let transport = result.context.transport {
        DemoLogger.shared.debug("Actual transport used: \(String(describing: transport))")
      }
    }
    recordSentColor()
  }

  private func recordSentColor() {
    lastSentColor = ColorWithMetadata(
      color: selectedColor,
      timestamp: Date(),
      source: "This Device"
    )
    messagesSent += 1
    logIfAvailable {
      DemoLogger.shared.debug("UI state updated - messagesSent: \(self.messagesSent)")
    }
  }

  /// Logs a live connectivity snapshot immediately before a send.
  private func logLiveState() async {
    guard #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) else {
      return
    }
    let liveReachable = await connectivityObserver.isReachable()
    let liveActivation = await connectivityObserver.getCurrentActivationState()
    let livePairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
    #if os(iOS)
      let livePaired = await connectivityObserver.isPaired()
    #else
      let livePaired = true
    #endif

    DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    DemoLogger.shared.debug("CONNECTIVITY STATE (LIVE)")
    DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    if let liveActivation {
      DemoLogger.shared.debug("Activation State: \(String(describing: liveActivation))")
    } else {
      DemoLogger.shared.debug("Activation State: not yet activated")
    }
    DemoLogger.shared.debug("isPaired: \(livePaired)")
    DemoLogger.shared.debug("isPairedAppInstalled: \(livePairedAppInstalled)")
    DemoLogger.shared.debug("isReachable: \(liveReachable)")
    DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  }
}
