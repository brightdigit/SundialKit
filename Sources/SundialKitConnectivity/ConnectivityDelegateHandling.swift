//
//  ConnectivityDelegateHandling.swift
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
  public import Foundation
  public import SundialKitCore
  import WatchConnectivity

  /// Protocol for handling connectivity session delegate callbacks.
  ///
  /// This protocol defines handler methods that process session state changes
  /// and received data from WatchConnectivity.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityDelegateHandling {
    /// Handles session activation completion.
    ///
    /// - Parameters:
    ///   - state: The activation state.
    ///   - error: Any error that occurred during activation.
    func handleActivation(_ state: ActivationState, error: (any Error)?)

    /// Handles session becoming inactive.
    func handleSessionInactive()

    /// Handles session deactivation.
    func handleSessionDeactivate()

    /// Handles reachability changes.
    ///
    /// - Parameter isReachable: Whether the counterpart is now reachable.
    func handleReachabilityChange(_ isReachable: Bool)

    /// Handles companion device state changes.
    ///
    /// - Parameter session: The connectivity session.
    func handleCompanionStateChange(_ session: any ConnectivitySession)

    /// Handles received messages.
    ///
    /// - Parameter message: The received message.
    func handleMessageReceived(_ message: ConnectivityMessage)

    /// Handles application context updates.
    ///
    /// - Parameters:
    ///   - applicationContext: The updated context.
    ///   - error: Any error that occurred.
    func handleApplicationContextReceived(
      _ applicationContext: ConnectivityMessage,
      error: (any Error)?
    )

    /// Handles received binary message data.
    ///
    /// - Parameters:
    ///   - messageData: The received binary data.
    ///   - replyHandler: Handler for sending a reply.
    func handleBinaryMessageReceived(
      _ messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    )
  }

  // MARK: - ConnectivitySessionDelegate Bridge

  extension ConnectivityDelegateHandling
  where Self: ConnectivityManager & ConnectivityObserverManaging {
    /// Called when session activation completes.
    public func session(
      _: any ConnectivitySession,
      activationDidCompleteWith activationState: ActivationState,
      error: (any Error)?
    ) {
      Task {
        await self.handleActivation(activationState, error: error)
      }
    }

    /// Called when the session becomes inactive (iOS only).
    public func sessionDidBecomeInactive(_: any ConnectivitySession) {
      Task {
        await handleSessionInactive()
      }
    }

    /// Called when the session deactivates (iOS only).
    public func sessionDidDeactivate(_: any ConnectivitySession) {
      
      Task {
        await handleSessionDeactivate()
      }
    }

    /// Called when companion state changes.
    public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
      
      Task {
        await handleCompanionStateChange(session)
      }
    }

    /// Called when reachability changes.
    public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
      
      Task {
        await handleReachabilityChange(session.isReachable)
      }
    }

    /// Called when a message is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveMessage message: ConnectivityMessage,
      replyHandler: @escaping ConnectivityHandler
    ) {
      
      Task {
        await handleMessageReceived(message)
      }
    }

    /// Called when application context is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      
      Task {
        await handleApplicationContextReceived(applicationContext, error: error)
      }
    }

    /// Called when binary message data is received.
    public func session(
      _: any ConnectivitySession,
      didReceiveMessageData messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      
      Task {
        await handleBinaryMessageReceived(messageData, replyHandler: replyHandler)
      }
    }
  }
#endif
