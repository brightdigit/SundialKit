//
//  MockSession.swift
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

import Foundation

@testable import SundialKitConnectivity
@testable import SundialKitCore

internal final class MockSession: ConnectivitySession, @unchecked Sendable {
  var receivedApplicationContext: ConnectivityMessage? {
    lastAppContext
  }
  internal var lastMessageSent: ConnectivityMessage?
  internal var lastAppContext: ConnectivityMessage?
  internal var nextReplyResult: Result<ConnectivityMessage, any Error>?
  internal var nextApplicationContextError: (any Error)?
  internal var isPaired = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  internal var delegate: (any ConnectivitySessionDelegate)?

  internal var isReachable = false {
    didSet {
      delegate?.sessionReachabilityDidChange(self)
    }
  }

  internal var isPairedAppInstalled = false {
    didSet {
      delegate?.sessionCompanionStateDidChange(self)
    }
  }

  internal var activationState: ActivationState = .notActivated {
    didSet {
      switch activationState {
      case .activated:
        delegate?.session(self, activationDidCompleteWith: activationState, error: nil)

      case .inactive:
        delegate?.sessionDidBecomeInactive(self)

      case .notActivated:
        delegate?.sessionDidDeactivate(self)
      }
    }
  }

  internal func activate() throws {
    activationState = .activated
  }

  internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
    if let nextApplicationContextError = nextApplicationContextError {
      throw nextApplicationContextError
    }
    lastAppContext = context
    delegate?.session(self, didReceiveApplicationContext: context, error: nil)
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
    // Mock implementation - just return empty data on success
    switch nextReplyResult {
    case .success:
      completion(.success(Data()))
    case .failure(let error):
      completion(.failure(error))
    case .none:
      completion(.success(Data()))
    }
  }

  internal func receiveMessage(
    _ message: ConnectivityMessage,
    withReplyHandler replyHandler: @escaping ConnectivityHandler
  ) {
    delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
  }
}
