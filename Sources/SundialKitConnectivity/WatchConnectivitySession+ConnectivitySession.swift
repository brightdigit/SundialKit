//
//  WatchConnectivitySession+ConnectivitySession.swift
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
    /// Whether the counterpart device is currently reachable for immediate message delivery.
    public var isReachable: Bool {
      session.isReachable
    }

    /// Whether the iPhone is paired with an Apple Watch (iOS only).
    public var isPaired: Bool {
      #if os(watchOS)
        true
      #else
        session.isPaired
      #endif
    }

    /// Whether the counterpart app is installed on the paired device.
    public var isPairedAppInstalled: Bool {
      session.isPairedAppInstalled
    }

    /// The current activation state of the session.
    public var activationState: ActivationState {
      guard let state = ActivationState(rawValue: session.activationState.rawValue) else {
        preconditionFailure()
      }

      return state
    }

    /// The most recent application context received from the counterpart device.
    ///
    /// This property contains the latest context dictionary sent via `updateApplicationContext(_:)`,
    /// even if it arrived while the app was inactive. Returns `nil` if no context has been received
    /// or if the context dictionary is empty.
    public var receivedApplicationContext: ConnectivityMessage? {
      let context = session.receivedApplicationContext
      guard !context.isEmpty else { return nil }
      return ConnectivityMessage(forceCasting: context)
    }

    /// Updates the application context to be sent to the counterpart device.
    ///
    /// The context is delivered opportunistically when the counterpart wakes up.
    /// Only the most recent context is preserved; previous contexts are replaced.
    ///
    /// - Parameter context: The dictionary to send as application context
    /// - Throws: An error if the context update fails
    public func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context as [String: Any])
    }

    /// Sends a message to the counterpart device with an optional reply.
    ///
    /// Requires the counterpart device to be reachable. Messages are delivered
    /// immediately and can include a reply from the counterpart.
    ///
    /// - Parameters:
    ///   - message: The dictionary message to send
    ///   - completion: Handler called with the reply or error
    public func sendMessage(
      _ message: ConnectivityMessage,
      _ completion: @escaping (Result<ConnectivityMessage, Error>) -> Void
    ) {
      session.sendMessage(
        message as [String: Any]
      ) { response in
        // WatchConnectivity only supports property list types which are inherently Sendable
        let sendableResponse = ConnectivityMessage(forceCasting: response)
        completion(.success(sendableResponse))
      } errorHandler: { error in
        completion(.failure(error))
      }
    }

    /// Sends binary message data to the counterpart device.
    ///
    /// This method provides direct binary transport for `BinaryMessagable` types.
    /// The binary data should include a type discrimination footer created by
    /// `BinaryMessageEncoder.encode(_:)`.
    ///
    /// - Parameters:
    ///   - data: The binary message data with type footer
    ///   - completion: Handler called with the result (reply data or error)
    public func sendMessageData(
      _ data: Data,
      _ completion: @escaping (Result<Data, Error>) -> Void
    ) {
      session.sendMessageData(
        data
      ) { responseData in
        completion(.success(responseData))
      } errorHandler: { error in
        completion(.failure(error))
      }
    }

    /// Activates the session to begin communication with the counterpart device.
    ///
    /// Must be called before any message exchange can occur.
    ///
    /// - Throws: `SundialError.sessionNotSupported` if WatchConnectivity is not supported
    public func activate() throws {
      guard WCSession.isSupported() else {
        throw SundialError.sessionNotSupported
      }
      session.activate()
    }
  }

#endif
