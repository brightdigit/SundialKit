//
//  TestObserver.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  /// Test observer for capturing ConnectivityManager state changes.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  internal final class TestObserver: ConnectivityStateObserver {
    // swiftlint:disable discouraged_optional_boolean
    internal var lastActivationState: ActivationState?
    internal var lastReachability: Bool?
    internal var lastCompanionAppInstalled: Bool?
    internal var lastPairedStatus: Bool?
    // swiftlint:enable discouraged_optional_boolean
    internal var lastMessage: ConnectivityMessage?
    internal var lastContext: ConnectivityMessage?

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeActivationState activationState: ActivationState
    ) {
      lastActivationState = activationState
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeReachability isReachable: Bool
    ) {
      lastReachability = isReachable
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didChangeCompanionAppInstalled isInstalled: Bool
    ) {
      lastCompanionAppInstalled = isInstalled
    }

    #if os(iOS)
      internal func connectivityManager(
        _: ConnectivityManager,
        didChangePairedStatus isPaired: Bool
      ) {
        lastPairedStatus = isPaired
      }
    #endif

    internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveMessage message: ConnectivityMessage
    ) {
      lastMessage = message
    }

    internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveApplicationContext context: ConnectivityMessage
    ) {
      lastContext = context
    }
  }
#endif
