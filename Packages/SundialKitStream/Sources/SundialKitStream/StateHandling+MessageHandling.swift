//
//  StateHandling+MessageHandling.swift
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

extension StateHandling where Self: MessageHandling & Sendable {
  // MARK: - ConnectivitySessionDelegate (nonisolated to receive callbacks)

  /// Handles session activation completion.
  nonisolated public func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith state: ActivationState,
    error: Error?
  ) {
    // Capture full session state snapshot at activation
    Task {
      await handleActivation(from: session, activationState: state, error: error)

      // Check for pending application context that arrived while inactive
      // This handles the case where updateApplicationContext was sent while the watch was unreachable
      if error == nil, state == .activated, let pendingContext = session.receivedApplicationContext {
        await handleApplicationContext(pendingContext, error: nil)
      }
    }
  }

  /// Handles session becoming inactive.
  nonisolated public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
    Task {
      await handleActivation(from: session, activationState: session.activationState, error: nil)
    }
  }

  /// Handles session deactivation.
  nonisolated public func sessionDidDeactivate(_ session: any ConnectivitySession) {
    Task {
      await handleActivation(from: session, activationState: session.activationState, error: nil)
    }
  }

  /// Handles reachability changes.
  nonisolated public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
    Task {
      await handleReachabilityChange(session.isReachable)

      // Check for pending application context when becoming reachable
      // This handles the case where updateApplicationContext was sent while unreachable
      if session.isReachable, let pendingContext = session.receivedApplicationContext {
        await handleApplicationContext(pendingContext, error: nil)
      }
    }
  }

  /// Handles companion device state changes.
  nonisolated public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
    Task { await handleCompanionStateChange(session) }
  }

  /// Handles received messages with reply handler.
  nonisolated public func session(
    _: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) {
    Task {
      await handleMessage(message, replyHandler: replyHandler)
    }
  }

  /// Handles application context updates.
  nonisolated public func session(
    _: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: Error?
  ) {
    Task {
      await handleApplicationContext(applicationContext, error: error)
    }
  }

  /// Handles received binary message data.
  nonisolated public func session(
    _: any ConnectivitySession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  ) {
    Task {
      await handleBinaryMessage(messageData, replyHandler: replyHandler)
    }
  }
}
