//
//  ConnectivityMessaging+Actor.swift
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
  public import SundialKitCore
  import WatchConnectivity

  // MARK: - Default Implementations for Actor-Based Messaging

  extension ConnectivityMessaging where Self: Actor {
    /// Sends a message to the counterpart device.
    ///
    /// This method provides actor-isolated access to messaging.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Called when a reply is received.
    ///   - errorHandler: Called if sending fails.
    public func sendMessage(
      _ message: ConnectivityMessage,
      replyHandler: @escaping (ConnectivityMessage) -> Void,
      errorHandler: @escaping (any Error) -> Void
    ) {
      session.sendMessage(message) { result in
        switch result {
        case .success(let reply):
          replyHandler(reply)
        case .failure(let error):
          errorHandler(error)
        }
      }
    }

    /// Updates the application context.
    ///
    /// This method provides actor-isolated access to context updates.
    ///
    /// - Parameter context: The context dictionary to send.
    /// - Throws: `ConnectivityError` if the update fails.
    public func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context)
    }
  }
#endif
