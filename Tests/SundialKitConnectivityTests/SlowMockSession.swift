//
//  SlowMockSession.swift
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

  /// Mock session that doesn't auto-activate to test slow activation scenarios.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  internal final class SlowMockSession: ConnectivitySession, @unchecked Sendable {
    var receivedApplicationContext: SundialKitCore.ConnectivityMessage? {
      lastAppContext
    }

    internal var lastMessageSent: ConnectivityMessage?
    internal var lastAppContext: ConnectivityMessage?
    internal var nextReplyResult: Result<ConnectivityMessage, any Error>?
    internal var nextApplicationContextError: (any Error)?
    internal var isPaired = false
    internal var delegate: (any ConnectivitySessionDelegate)?
    internal var isReachable = false
    internal var isPairedAppInstalled = false

    internal var activationState: ActivationState = .notActivated {
      didSet {
        delegate?.session(self, activationDidCompleteWith: activationState, error: nil)
      }
    }

    internal func activate() throws {
      // Don't automatically change state - tests will do this manually
    }

    internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
      if let nextApplicationContextError = nextApplicationContextError {
        throw nextApplicationContextError
      }
      lastAppContext = context
    }

    internal func sendMessage(
      _ message: ConnectivityMessage,
      _ replyHandler: @escaping (Result<ConnectivityMessage, any Error>) -> Void
    ) {
      lastMessageSent = message
      replyHandler(nextReplyResult ?? .success([:]))
    }

    internal func sendMessageData(
      _ data: Data,
      _ completion: @escaping (Result<Data, any Error>) -> Void
    ) {
      completion(.success(Data()))
    }
  }
#endif
