//
//  StreamMessageLabViewModel+Streams.swift
//  Sundial
//
//  Copyright (c) 2025 BrightDigit.
//

import Foundation
import Observation
import os.log
import SundialDemoShared
import SundialKitConnectivity
import SundialKitCore
import SundialKitStream
import SwiftUI

@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
extension StreamMessageLabViewModel {
  /// Logs a snapshot of connectivity state ~500ms after activation.
  internal func logInitialState() async {
    let reachable = await connectivityObserver.isReachable()
    let activationState = await connectivityObserver.getCurrentActivationState()
    let pairedAppInstalled = await connectivityObserver.isPairedAppInstalled()
    #if os(iOS)
      let paired = await connectivityObserver.isPaired()
    #else
      let paired = true
    #endif

    logIfAvailable {
      DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      DemoLogger.shared.debug("INITIAL STATE (500ms after activation)")
      DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
      if let activationState {
        DemoLogger.shared.debug("Activation State: \(String(describing: activationState))")
      } else {
        DemoLogger.shared.debug("Activation State: nil")
      }
      DemoLogger.shared.debug("isPaired: \(paired)")
      DemoLogger.shared.debug("isPairedAppInstalled: \(pairedAppInstalled)")
      DemoLogger.shared.debug("isReachable: \(reachable)")
      #if os(watchOS)
        DemoLogger.shared.debug("Watch app perspective")
      #elseif os(iOS)
        DemoLogger.shared.debug("iPhone app perspective")
      #endif
      DemoLogger.shared.debug("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    }
  }

  internal func consumeTypedMessages() async {
    for await message in await connectivityObserver.typedMessageStream() {
      logIfAvailable {
        DemoLogger.shared.debug(
          "Received typed message: \(String(describing: type(of: message)))"
        )
      }
      handleReceivedTypedMessage(message)
    }
  }

  internal func consumeReachability() async {
    for await reachable in await connectivityObserver.reachabilityUpdates() {
      logIfAvailable { DemoLogger.shared.info("Reachability changed: \(reachable)") }
      isReachable = reachable
    }
  }

  internal func consumeActivationState() async {
    for await state in await connectivityObserver.activationStates() {
      logIfAvailable {
        DemoLogger.shared.info("Activation state changed: \(String(describing: state))")
      }
      activationState = state
    }
  }

  #if os(iOS)
    internal func consumePairedStatus() async {
      for await paired in await connectivityObserver.pairedUpdates() {
        logIfAvailable { DemoLogger.shared.info("Paired status changed: \(paired)") }
        isPaired = paired
      }
    }
  #endif

  internal func consumePairedAppInstalledStatus() async {
    for await installed in await connectivityObserver.pairedAppInstalledUpdates() {
      logIfAvailable {
        DemoLogger.shared.info("Paired app installed status changed: \(installed)")
      }
      isPairedAppInstalled = installed
    }
  }
}
