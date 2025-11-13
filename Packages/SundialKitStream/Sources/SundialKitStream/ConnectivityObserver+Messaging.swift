//
//  ConnectivityObserver+Messaging.swift
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
public import SundialKitConnectivity
public import SundialKitCore

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension ConnectivityObserver {
  // MARK: - Message Sending

  /// Sends a message to the counterpart device
  /// - Parameter message: The message to send (must be property list types)
  /// - Returns: The send result
  /// - Throws: Error if the message cannot be sent
  public func sendMessage(_ message: ConnectivityMessage) async throws -> ConnectivitySendResult {
    do {
      let sendResult = try await messageRouter.send(message)

      // Notify send result stream subscribers
      await messageDistributor.notifySendResult(sendResult)

      return sendResult
    } catch {
      let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

      // Notify send result stream subscribers
      await messageDistributor.notifySendResult(sendResult)

      throw error
    }
  }

  /// Sends a typed message with automatic transport selection
  ///
  /// Automatically chooses the best transport based on message type:
  /// - `BinaryMessagable` types use binary transport (unless `forceDictionary` option is set)
  /// - `Messagable` types use dictionary transport
  ///
  /// ## Example
  ///
  /// ```swift
  /// // Binary transport (efficient)
  /// let sensor = SensorData(temperature: 72.5)
  /// let result = try await observer.send(sensor)
  ///
  /// // Dictionary transport
  /// let status = StatusMessage(text: "ready")
  /// let result = try await observer.send(status)
  ///
  /// // Force dictionary for testing
  /// let result = try await observer.send(sensor, options: .forceDictionary)
  /// ```
  ///
  /// - Parameters:
  ///   - message: The typed message to send
  ///   - options: Send options (e.g., `.forceDictionary`)
  /// - Returns: The send result with transport indication
  /// - Throws: Error if the message cannot be sent
  public func send(_ message: some Messagable, options: SendOptions = []) async throws
    -> ConnectivitySendResult
  {
    // Determine transport based on type and options
    if let binaryMessage = message as? any BinaryMessagable,
      !options.contains(.forceDictionary)
    {
      // Binary transport
      let data = try BinaryMessageEncoder.encode(binaryMessage)
      let originalMessage = message.message()

      do {
        let sendResult = try await messageRouter.sendBinary(data, originalMessage: originalMessage)

        // Notify send result stream subscribers
        await messageDistributor.notifySendResult(sendResult)

        return sendResult
      } catch {
        let sendResult = ConnectivitySendResult(
          message: originalMessage,
          context: .failure(error)
        )

        // Notify send result stream subscribers
        await messageDistributor.notifySendResult(sendResult)

        throw error
      }
    } else {
      // Dictionary transport
      return try await sendMessage(message.message())
    }
  }
}
