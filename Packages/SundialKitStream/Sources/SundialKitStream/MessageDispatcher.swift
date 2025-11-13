//
//  MessageDispatcher.swift
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

import Foundation
import os
import SundialKitConnectivity
import SundialKitCore

/// Internal helper for dispatching received messages to stream subscribers.
///
/// `MessageDispatcher` handles the distribution of incoming messages to various
/// stream continuations, including:
/// - Raw message streams (with reply handlers)
/// - Typed message streams (decoded via `MessageDecoder`)
/// - Application context messages
/// - Binary message streams
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
internal struct MessageDispatcher {
  // MARK: - Private Properties

  private let messageDecoder: MessageDecoder?

  // MARK: - Initialization

  /// Creates a new message dispatcher.
  ///
  /// - Parameter messageDecoder: Optional decoder for automatic message decoding
  internal init(messageDecoder: MessageDecoder?) {
    self.messageDecoder = messageDecoder
  }

  // MARK: - Message Dispatching

  /// Dispatches a received message to stream subscribers.
  ///
  /// Sends the message to both raw message streams and typed message streams
  /// (if a decoder is available).
  ///
  /// - Parameters:
  ///   - message: The received message
  ///   - replyHandler: Handler for sending a reply
  ///   - messageRegistry: Registry of raw message stream continuations
  ///   - typedRegistry: Registry of typed message stream continuations
  internal func dispatchMessage(
    _ message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void,
    to messageRegistry: StreamContinuationRegistry<ConnectivityReceiveResult>,
    and typedRegistry: StreamContinuationRegistry<Messagable>
  ) {
    // Verify decoder exists if typed subscribers are registered
    assert(
      messageDecoder != nil || typedRegistry.isEmpty,
      "Typed message subscribers exist but no decoder is configured"
    )

    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(message: message, context: .replyWith(replyHandler))
    messageRegistry.yield(result)

    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(message)
        typedRegistry.yield(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode message: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(.error, "Failed to decode message: %{public}@", String(describing: error))
      }
    }
  }

  /// Dispatches an application context message to stream subscribers.
  ///
  /// - Parameters:
  ///   - context: The application context dictionary
  ///   - error: Optional error that occurred during context update
  ///   - messageRegistry: Registry of raw message stream continuations
  ///   - typedRegistry: Registry of typed message stream continuations
  internal func dispatchApplicationContext(
    _ context: ConnectivityMessage,
    error: Error?,
    to messageRegistry: StreamContinuationRegistry<ConnectivityReceiveResult>,
    and typedRegistry: StreamContinuationRegistry<Messagable>
  ) {
    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(message: context, context: .applicationContext)
    messageRegistry.yield(result)

    // Decode and send to typed stream subscribers if no error
    if error == nil, let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(context)
        typedRegistry.yield(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode application context: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(
          .error, "Failed to decode application context: %{public}@", String(describing: error))
      }
    }
  }

  /// Dispatches a binary message to stream subscribers.
  ///
  /// Attempts to decode the binary message using the MessageDecoder's decodeBinary method
  /// and dispatches to typed streams. Binary messages are not sent to raw message streams.
  ///
  /// - Parameters:
  ///   - data: The binary message data
  ///   - replyHandler: Handler for sending a binary reply
  ///   - typedRegistry: Registry of typed message stream continuations
  internal func dispatchBinaryMessage(
    _ data: Data,
    replyHandler: @escaping @Sendable (Data) -> Void,
    to typedRegistry: StreamContinuationRegistry<any Messagable>
  ) {
    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decodeBinary(data)
        typedRegistry.yield(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode binary message: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(.error, "Failed to decode binary message: %{public}@", String(describing: error))
      }
    }
  }
}
