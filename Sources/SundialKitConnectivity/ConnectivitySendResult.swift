//
//  ConnectivitySendResult.swift
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

/// Result of sending a message via WatchConnectivity.
///
/// Contains the reply message (if any) and context about how the message was sent
/// (direct message with reply, application context, or failure).
///
/// ## Example
///
/// ```swift
/// let result = try await observer.send(ColorMessage(red: 1.0, green: 0, blue: 0))
///
/// switch result.context {
/// case .reply(let replyMessage, let transport):
///   print("Sent via \(transport), reply: \(replyMessage)")
///
/// case .applicationContext(let transport):
///   print("Queued via application context using \(transport)")
///
/// case .failure(let error):
///   print("Failed: \(error)")
/// }
/// ```
public struct ConnectivitySendResult: Sendable {
  /// The reply message received from the counterpart, if any.
  ///
  /// Contains the dictionary payload in the reply. For `.applicationContext` sends,
  /// this will be empty since application context doesn't support replies.
  public let message: ConnectivityMessage

  /// Context indicating how the message was sent and the outcome.
  ///
  /// Includes the transport mechanism used (dictionary vs binary) and whether
  /// a reply was received or the message was queued via application context.
  public let context: ConnectivitySendContext

  /// Creates a new send result.
  /// - Parameters:
  ///   - message: The message that was sent
  ///   - context: How the message was sent
  public init(message: ConnectivityMessage, context: ConnectivitySendContext) {
    self.message = message
    self.context = context
  }
}
