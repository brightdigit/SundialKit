//
//  ConnectivityObserver+Methods.swift
//  SundialKitCombine
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

#if canImport(Combine)
  public import Combine
  public import Foundation
  public import SundialKitConnectivity
  public import SundialKitCore

  extension ConnectivityObserver {
    #if canImport(WatchConnectivity)
      /// Creates a `ConnectivityObserver` which uses WatchConnectivity
      /// - Parameter messageDecoder: Optional decoder for automatic message decoding
      @available(macOS, unavailable)
      @available(tvOS, unavailable)
      public convenience init(messageDecoder: MessageDecoder? = nil) {
        self.init(session: WatchConnectivitySession(), messageDecoder: messageDecoder)
      }
    #else
      /// Creates a `ConnectivityObserver` with a never-available session
      /// - Parameter messageDecoder: Optional decoder for automatic message decoding
      @available(macOS, unavailable)
      @available(tvOS, unavailable)
      public convenience init(messageDecoder: MessageDecoder? = nil) {
        self.init(session: NeverConnectivitySession(), messageDecoder: messageDecoder)
      }
    #endif

    // MARK: - Public API

    /// Activates the connectivity session
    /// - Throws: `ConnectivityError.sessionNotSupported` if not supported
    public func activate() throws {
      try session.activate()
    }

    /// Sends a message to the counterpart device
    /// - Parameter message: The message to send (must be property list types)
    /// - Returns: The send result
    /// - Throws: Error if the message cannot be sent
    public func sendMessage(_ message: ConnectivityMessage) async throws -> ConnectivitySendResult {
      if session.isReachable {
        // Use sendMessage for immediate delivery when reachable
        return try await withCheckedThrowingContinuation { continuation in
          session.sendMessage(message) { result in
            let sendResult = ConnectivitySendResult(message: message, context: .init(result))

            // Notify subscribers on main thread
            Task { @MainActor in
              self.sendResult.send(sendResult)
            }

            continuation.resume(returning: sendResult)
          }
        }
      } else if session.isPairedAppInstalled {
        // Use application context for background delivery
        do {
          try session.updateApplicationContext(message)
          let sendResult = ConnectivitySendResult(
            message: message, context: .applicationContext(transport: .dictionary)
          )

          // Notify subscribers
          self.sendResult.send(sendResult)

          return sendResult
        } catch {
          let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

          // Notify subscribers
          self.sendResult.send(sendResult)

          throw error
        }
      } else {
        // No way to deliver the message
        let error = SundialError.missingCompanion
        let sendResult = ConnectivitySendResult(message: message, context: .failure(error))

        // Notify subscribers
        self.sendResult.send(sendResult)

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
      if let binaryMessage = message as? any BinaryMessagable, !options.contains(.forceDictionary) {
        // Binary transport

        let data = try BinaryMessageEncoder.encode(binaryMessage)

        if session.isReachable {
          let sendResult = await session.sendBinaryData(data, message: message)
          Task { @MainActor in
            self.sendResult.send(sendResult)
          }
          if case .failure(let error) = sendResult.context {
            throw error
          }
          return sendResult
        } else {
          // Binary messages require reachability - can't use application context
          let error = SundialError.missingCompanion
          let sendResult = ConnectivitySendResult(
            message: message.message(),
            context: .failure(error)
          )
          self.sendResult.send(sendResult)
          throw error
        }
      } else {
        // Dictionary transport
        return try await sendMessage(message.message())
      }
    }
  }
#endif
