//
//  MessageDistributor.swift
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

public import Foundation
import os
public import SundialKitConnectivity
public import SundialKitCore

/// Distributes incoming messages to appropriate stream subscribers
///
/// This type handles message decoding and distribution to both
/// raw message streams and typed message streams.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public actor MessageDistributor {
  // MARK: - Properties

  private let continuationManager: StreamContinuationManager
  private let messageDecoder: MessageDecoder?

  // MARK: - Initialization

  internal init(
    continuationManager: StreamContinuationManager,
    messageDecoder: MessageDecoder?
  ) {
    self.continuationManager = continuationManager
    self.messageDecoder = messageDecoder
  }

  // MARK: - Message Handling

  internal func handleMessage(
    _ message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) async {
    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(message: message, context: .replyWith(replyHandler))
    await continuationManager.yieldMessageReceived(result)

    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(message)
        await continuationManager.yieldTypedMessage(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode message: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(.error, "Failed to decode message: %{public}@", String(describing: error))
      }
    }
  }

  internal func handleApplicationContext(
    _ applicationContext: ConnectivityMessage,
    error: (any Error)?
  ) async {
    // Send to raw stream subscribers
    let result = ConnectivityReceiveResult(
      message: applicationContext,
      context: .applicationContext
    )
    await continuationManager.yieldMessageReceived(result)

    // Decode and send to typed stream subscribers if no error
    if error == nil, let decoder = messageDecoder {
      do {
        let decoded = try decoder.decode(applicationContext)
        await continuationManager.yieldTypedMessage(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode application context: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(.error, "Failed to decode application context: %{public}@", String(describing: error))
      }
    }
  }

  internal func handleBinaryMessage(
    _ data: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  ) async {
    // Decode and send to typed stream subscribers
    if let decoder = messageDecoder {
      do {
        let decoded = try decoder.decodeBinary(data)
        await continuationManager.yieldTypedMessage(decoded)
      } catch {
        // Decoding failed - crash in debug, log in production
        assertionFailure("Failed to decode binary message: \(error)")
        #warning("Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
        os_log(.error, "Failed to decode binary message: %{public}@", String(describing: error))
      }
    }
  }

  internal func notifySendResult(_ result: ConnectivitySendResult) async {
    await continuationManager.yieldSendResult(result)
  }
}
