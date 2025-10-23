//
//  ConnectivityObserver+Delegate.swift
//  SundialKitStream
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

public import Foundation
public import SundialKitConnectivity
public import SundialKitCore

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension ConnectivityObserver {
  // MARK: - ConnectivitySessionDelegate (nonisolated to receive callbacks)

  nonisolated public func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith state: ActivationState,
    error: Error?
  ) {
    Task { await handleActivation(state, error: error) }
  }

  nonisolated public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
    Task { await handleActivation(session.activationState, error: nil) }
  }

  nonisolated public func sessionDidDeactivate(_ session: any ConnectivitySession) {
    Task { await handleActivation(session.activationState, error: nil) }
  }

  nonisolated public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
    Task { await handleReachabilityChange(session.isReachable) }
  }

  nonisolated public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
    Task { await handleCompanionStateChange(session) }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) {
    Task {
      await handleMessage(message, replyHandler: replyHandler)
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: Error?
  ) {
    Task {
      await handleApplicationContext(applicationContext, error: error)
    }
  }

  nonisolated public func session(
    _ session: any ConnectivitySession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  ) {
    Task {
      await handleBinaryMessage(messageData, replyHandler: replyHandler)
    }
  }
}
