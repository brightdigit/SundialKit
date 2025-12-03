//
//  ConnectivitySendContext.swift
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

/// Result context from sending a message, indicating delivery method and outcome.
///
/// This enum represents the outcome of a send operation, including whether it succeeded,
/// how it was sent (application context vs direct message), what transport was used
/// (dictionary vs binary), and any reply received.
///
/// ## Example
///
/// ```swift
/// let result = try await observer.send(myMessage)
/// switch result.context {
/// case .reply(let replyMessage, transport: .binary):
///   print("Sent via binary transport, received reply: \(replyMessage)")
///
/// case .applicationContext(transport: .dictionary):
///   print("Sent via application context (counterpart unreachable)")
///
/// case .failure(let error):
///   print("Send failed: \(error)")
/// }
/// ```
public enum ConnectivitySendContext: Sendable {
  /// Message sent via application context (background delivery).
  ///
  /// Used when the counterpart device is unreachable. The message will be delivered
  /// when the devices can communicate. This corresponds to WatchConnectivity's
  /// `updateApplicationContext(_:)`.
  ///
  /// - Parameter transport: The transport mechanism used (`.dictionary` or `.binary`)
  case applicationContext(transport: MessageTransport)

  /// Message sent successfully with a reply received.
  ///
  /// Used when the counterpart device is reachable and responded to the message.
  /// This corresponds to WatchConnectivity's `sendMessage(_:replyHandler:)` or
  /// `sendMessageData(_:replyHandler:)`.
  ///
  /// - Parameters:
  ///   - reply: The reply message received from the counterpart
  ///   - transport: The transport mechanism used (`.dictionary` or `.binary`)
  case reply(ConnectivityMessage, transport: MessageTransport)

  /// Message send failed with an error.
  ///
  /// - Parameter error: The error that caused the send to fail
  case failure(any Error)
}

extension ConnectivitySendContext {
  /// The transport mechanism used for this send operation, if applicable.
  /// Returns `nil` for failure cases.
  public var transport: MessageTransport? {
    switch self {
    case .applicationContext(let transport), .reply(_, let transport):
      return transport
    case .failure:
      return nil
    }
  }

  /// Creates a send context from a result.
  /// - Parameters:
  ///   - result: The result of sending a message
  ///   - transport: The transport mechanism used (defaults to `.dictionary`)
  public init(
    _ result: Result<ConnectivityMessage, any Error>, transport: MessageTransport = .dictionary
  ) {
    switch result {
    case .success(let message):
      self = .reply(message, transport: transport)

    case .failure(let error):
      self = .failure(error)
    }
  }
}
