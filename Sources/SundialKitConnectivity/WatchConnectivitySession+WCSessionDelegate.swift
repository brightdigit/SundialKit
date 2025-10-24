//
//  WatchConnectivitySession+WCSessionDelegate.swift
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

  extension WatchConnectivitySession {
    internal func session(
      _: WCSession,
      activationDidCompleteWith activationState: WCSessionActivationState,
      error: Error?
    ) {
      guard
        let activationState: ActivationState =
          .init(rawValue: activationState.rawValue)
      else {
        preconditionFailure()
      }
      delegate?.session(
        self,
        activationDidCompleteWith: activationState,
        error: error
      )
    }

    #if os(iOS)

      internal func sessionDidBecomeInactive(_: WCSession) {
        delegate?.sessionDidBecomeInactive(self)
      }

      internal func sessionDidDeactivate(_: WCSession) {
        delegate?.sessionDidDeactivate(self)
      }

      internal func sessionWatchStateDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
      }

    #elseif os(watchOS)

      internal func sessionCompanionAppInstalledDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
      }
    #endif

    internal func sessionReachabilityDidChange(_: WCSession) {
      delegate?.sessionReachabilityDidChange(self)
    }

    internal func session(
      _: WCSession,
      didReceiveMessage message: [String: Any],
      replyHandler: @escaping ([String: Any]) -> Void
    ) {
      // WatchConnectivity only supports property list types which are inherently Sendable
      let sendableMessage = ConnectivityMessage(forceCasting: message)
      let handler = unsafeBitCast(replyHandler, to: ConnectivityHandler.self)
      delegate?.session(self, didReceiveMessage: sendableMessage, replyHandler: handler)
    }

    internal func session(
      _: WCSession,
      didReceiveApplicationContext applicationContext: [String: Any]
    ) {
      // WatchConnectivity only supports property list types which are inherently Sendable
      let sendableContext = ConnectivityMessage(forceCasting: applicationContext)
      delegate?.session(
        self,
        didReceiveApplicationContext: sendableContext,
        error: nil
      )
    }

    internal func session(
      _: WCSession,
      didReceiveApplicationContext applicationContext: [String: Any],
      error: Error?
    ) {
      // WatchConnectivity only supports property list types which are inherently Sendable
      let sendableContext = ConnectivityMessage(forceCasting: applicationContext)
      delegate?.session(
        self,
        didReceiveApplicationContext: sendableContext,
        error: error
      )
    }

    internal func session(
      _: WCSession,
      didReceiveMessageData messageData: Data,
      replyHandler: @escaping (Data) -> Void
    ) {
      let handler = unsafeBitCast(replyHandler, to: (@Sendable (Data) -> Void).self)
      delegate?.session(self, didReceiveMessageData: messageData, replyHandler: handler)
    }
  }

#endif
