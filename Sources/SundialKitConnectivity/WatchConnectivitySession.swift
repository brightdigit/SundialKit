//
//  WatchConnectivitySession.swift
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

  internal typealias WatchConnectivitySessionProtocol =
    ConnectivitySession & WCSessionDelegate

  public final class WatchConnectivitySession: NSObject, WatchConnectivitySessionProtocol,
    @unchecked Sendable
  {
    private let session: WCSession

    public var delegate: ConnectivitySessionDelegate?

    public var isReachable: Bool {
      session.isReachable
    }

    @available(watchOS, unavailable)
    public var isPaired: Bool {
      session.isPaired
    }

    public var isPairedAppInstalled: Bool {
      session.isPairedAppInstalled
    }

    public var activationState: ActivationState {
      guard let state = ActivationState(rawValue: session.activationState.rawValue) else {
        preconditionFailure()
      }

      return state
    }

    internal init(session: WCSession) {
      self.session = session
      super.init()
      session.delegate = self
    }

    override public convenience init() {
      self.init(session: .default)
    }

    public func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context as [String: Any])
    }

    public func sendMessage(
      _ message: ConnectivityMessage,
      _ completion: @escaping (Result<ConnectivityMessage, Error>) -> Void
    ) {
      session.sendMessage(
        message as [String: Any]
      ) { response in
        let sendableResponse: ConnectivityMessage = response.mapValues { $0 as! any Sendable }
        completion(.success(sendableResponse))
      } errorHandler: { error in
        completion(.failure(error))
      }
    }

    public func activate() throws {
      guard WCSession.isSupported() else {
        throw SundialError.sessionNotSupported
      }
      session.activate()
    }

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
      let sendableMessage: ConnectivityMessage = message.mapValues { $0 as! any Sendable }
      let handler = unsafeBitCast(replyHandler, to: ConnectivityHandler.self)
      delegate?.session(self, didReceiveMessage: sendableMessage, replyHandler: handler)
    }

    internal func session(
      _: WCSession,
      didReceiveApplicationContext applicationContext: [String: Any]
    ) {
      let sendableContext: ConnectivityMessage = applicationContext.mapValues { $0 as! any Sendable }
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
      let sendableContext: ConnectivityMessage = applicationContext.mapValues { $0 as! any Sendable }
      delegate?.session(
        self,
        didReceiveApplicationContext: sendableContext,
        error: error
      )
    }
  }

#endif
