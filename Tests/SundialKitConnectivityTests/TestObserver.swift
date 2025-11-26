//
// TestObserver.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  /// Test observer for capturing ConnectivityManager state changes.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  internal actor TestObserver: ConnectivityStateObserver {
    // swiftlint:disable discouraged_optional_boolean
    internal var lastActivationState: ActivationState?
    internal var lastReachability: Bool?
    internal var lastCompanionAppInstalled: Bool?
    internal var lastPairedStatus: Bool?
    // swiftlint:enable discouraged_optional_boolean
    internal var lastMessage: ConnectivityMessage?
    internal var lastContext: ConnectivityMessage?

    nonisolated internal func connectivityManager(
      _: ConnectivityManager,
      didChangeActivationState activationState: ActivationState
    ) {
      Task {
        await self.setLastActivationState(activationState)
      }
    }

    nonisolated internal func connectivityManager(
      _: ConnectivityManager,
      didChangeReachability isReachable: Bool
    ) {
      Task {
        await self.setLastReachability(isReachable)
      }
    }

    nonisolated internal func connectivityManager(
      _: ConnectivityManager,
      didChangeCompanionAppInstalled isInstalled: Bool
    ) {
      Task {
        await self.setLastCompanionAppInstalled(isInstalled)
      }
    }

    #if os(iOS)
      nonisolated internal func connectivityManager(
        _: ConnectivityManager,
        didChangePairedStatus isPaired: Bool
      ) {
        Task {
          await self.setLastPairedStatus(isPaired)
        }
      }
    #endif

    nonisolated internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveMessage message: ConnectivityMessage
    ) {
      Task {
        await self.setLastMessage(message)
      }
    }

    nonisolated internal func connectivityManager(
      _: ConnectivityManager,
      didReceiveApplicationContext context: ConnectivityMessage
    ) {
      Task {
        await self.setLastContext(context)
      }
    }

    // MARK: - Actor-Isolated Setters

    private func setLastActivationState(_ state: ActivationState) {
      lastActivationState = state
    }

    private func setLastReachability(_ isReachable: Bool) {
      lastReachability = isReachable
    }

    private func setLastCompanionAppInstalled(_ isInstalled: Bool) {
      lastCompanionAppInstalled = isInstalled
    }

    #if os(iOS)
      private func setLastPairedStatus(_ isPaired: Bool) {
        lastPairedStatus = isPaired
      }
    #endif

    private func setLastMessage(_ message: ConnectivityMessage) {
      lastMessage = message
    }

    private func setLastContext(_ context: ConnectivityMessage) {
      lastContext = context
    }
  }
#endif
