//
//  TestObserver.swift
//  SundialKit
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
