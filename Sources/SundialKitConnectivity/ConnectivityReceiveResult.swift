//
//  ConnectivityReceiveResult.swift
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

/// Result of receiving a message from WatchConnectivity.
///
/// Contains the received message payload and context about how it was received
/// (interactive with reply handler, or one-way application context update).
///
/// ## Example
///
/// ```swift
/// // Using SundialKitStream
/// for await result in await observer.messageStream() {
///   print("Received: \(result.message)")
///
///   // Handle based on context
///   if let handler = result.context.replyHandler {
///     handler(["status": "received"])
///   }
/// }
/// ```
public struct ConnectivityReceiveResult: Sendable {
  /// The message that was received.
  ///
  /// Contains the dictionary payload sent by the counterpart device.
  public let message: ConnectivityMessage

  /// Context indicating how the message was received.
  ///
  /// Determines whether this is an interactive message requiring a reply
  /// or a one-way application context update.
  public let context: ConnectivityReceiveContext

  /// Creates a new receive result.
  /// - Parameters:
  ///   - message: The message that was received
  ///   - context: How the message was received
  public init(message: ConnectivityMessage, context: ConnectivityReceiveContext) {
    self.message = message
    self.context = context
  }
}
