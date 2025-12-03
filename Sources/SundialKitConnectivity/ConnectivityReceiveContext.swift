//
//  ConnectivityReceiveContext.swift
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

public import SundialKitCore

/// Context indicating how a message was received and how to handle it.
///
/// This enum distinguishes between interactive messages that expect a reply
/// and one-way state updates sent via application context.
///
/// ## Example
///
/// ```swift
/// // Using SundialKitStream
/// for await result in await observer.messageStream() {
///   switch result.context {
///   case .replyWith(let handler):
///     // Interactive message - send a reply
///     print("Received: \(result.message)")
///     handler(["status": "acknowledged"])
///
///   case .applicationContext:
///     // One-way update - no reply expected
///     print("State update: \(result.message)")
///   }
/// }
/// ```
public enum ConnectivityReceiveContext: Sendable {
  /// Received as an interactive message with a reply handler.
  ///
  /// The associated handler should be called to send a reply back to the sender.
  /// This corresponds to WatchConnectivity's `session(_:didReceiveMessage:replyHandler:)`.
  case replyWith(@Sendable (ConnectivityMessage) -> Void)

  /// Received as a one-way application context update.
  ///
  /// No reply is expected or possible. This corresponds to WatchConnectivity's
  /// `session(_:didReceiveApplicationContext:)`.
  case applicationContext

  /// The reply handler if it contains one.
  public var replyHandler: ConnectivityHandler? {
    guard case .replyWith(let handler) = self else {
      return nil
    }
    return handler
  }

  /// If this was from application context.
  public var isApplicationContext: Bool {
    guard case .applicationContext = self else {
      return false
    }
    return true
  }
}
