//
//  MessageHandling.swift
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

internal import Foundation
internal import SundialKitConnectivity
internal import SundialKitCore

/// Protocol for types that handle connectivity message distribution
///
/// Provides default implementations for common message handling patterns
/// by delegating to a `MessageDistributor`.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public protocol MessageHandling {
  /// The message distributor responsible for routing messages to subscribers
  var messageDistributor: MessageDistributor { get }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension MessageHandling {
  /// Handles received dictionary messages
  /// - Parameters:
  ///   - message: The received message dictionary
  ///   - replyHandler: Handler to send a reply back to the sender
  internal func handleMessage(
    _ message: ConnectivityMessage,
    replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
  ) async {
    await messageDistributor.handleMessage(message, replyHandler: replyHandler)
  }

  /// Handles application context updates
  /// - Parameters:
  ///   - applicationContext: The updated application context
  ///   - error: Optional error that occurred during context update
  internal func handleApplicationContext(_ applicationContext: ConnectivityMessage, error: Error?)
    async
  {
    await messageDistributor.handleApplicationContext(applicationContext, error: error)
  }

  /// Handles received binary messages
  /// - Parameters:
  ///   - data: The received binary data
  ///   - replyHandler: Handler to send binary data back to the sender
  internal func handleBinaryMessage(_ data: Data, replyHandler: @escaping @Sendable (Data) -> Void)
    async
  {
    await messageDistributor.handleBinaryMessage(data, replyHandler: replyHandler)
  }
}
