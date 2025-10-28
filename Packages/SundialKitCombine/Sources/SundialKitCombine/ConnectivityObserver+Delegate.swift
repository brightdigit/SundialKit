//
//  ConnectivityObserver+Delegate.swift
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

  // MARK: - ConnectivitySessionDelegate

  @MainActor
  extension ConnectivityObserver {
    /// Handles session activation completion.
    nonisolated public func session(
      _ session: any ConnectivitySession,
      activationDidCompleteWith state: ActivationState,
      error: (any Error)?
    ) {
      // Extract values before crossing isolation boundary
      let isReachable = session.isReachable
      let isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        let isPaired = session.isPaired
      #endif

      Task { @MainActor in
        self.activationState = state
        self.activationError = error
        self.isReachable = isReachable
        self.isPairedAppInstalled = isPairedAppInstalled
        #if os(iOS)
          self.isPaired = isPaired
        #endif

        // Publish activation completion event
        if let error = error {
          self.activationCompleted.send(.failure(error))
        } else {
          self.activationCompleted.send(.success(state))
        }
      }
    }

    /// Handles when session becomes inactive.
    nonisolated public func sessionDidBecomeInactive(_ session: any ConnectivitySession) {
      // Extract value before crossing isolation boundary
      let activationState = session.activationState

      Task { @MainActor in
        self.activationState = activationState
      }
    }

    /// Handles session deactivation.
    nonisolated public func sessionDidDeactivate(_ session: any ConnectivitySession) {
      // Extract value before crossing isolation boundary
      let activationState = session.activationState

      Task { @MainActor in
        self.activationState = activationState
      }
    }

    /// Handles when session reachability changes.
    nonisolated public func sessionReachabilityDidChange(_ session: any ConnectivitySession) {
      // Extract value before crossing isolation boundary
      let isReachable = session.isReachable

      Task { @MainActor in
        self.isReachable = isReachable
      }
    }

    /// Handles companion device state changes.
    nonisolated public func sessionCompanionStateDidChange(_ session: any ConnectivitySession) {
      // Extract values before crossing isolation boundary
      let isPairedAppInstalled = session.isPairedAppInstalled
      #if os(iOS)
        let isPaired = session.isPaired
      #endif

      Task { @MainActor in
        self.isPairedAppInstalled = isPairedAppInstalled
        #if os(iOS)
          self.isPaired = isPaired
        #endif
      }
    }

    /// Handles received message with reply handler.
    nonisolated public func session(
      _ session: any ConnectivitySession,
      didReceiveMessage message: ConnectivityMessage,
      replyHandler: @escaping @Sendable ([String: any Sendable]) -> Void
    ) {
      Task { @MainActor in
        // Send to raw publisher
        let result = ConnectivityReceiveResult(message: message, context: .replyWith(replyHandler))
        self.messageReceived.send(result)

        // Decode and send to typed publisher
        if let decoder = self.messageDecoder {
          do {
            let decoded = try decoder.decode(message)
            self.typedMessageReceived.send(decoded)
          } catch {
            // Decoding failed - log but don't crash (raw publisher still gets the message)
            #warning(
              "Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
            print("Failed to decode message: \(error)")
          }
        }
      }
    }

    /// Handles received application context.
    nonisolated public func session(
      _ session: any ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error: (any Error)?
    ) {
      Task { @MainActor in
        // Send to raw publisher
        let result = ConnectivityReceiveResult(
          message: applicationContext, context: .applicationContext
        )
        self.messageReceived.send(result)

        // Decode and send to typed publisher
        if let decoder = self.messageDecoder {
          do {
            let decoded = try decoder.decode(applicationContext)
            self.typedMessageReceived.send(decoded)
          } catch {
            // Decoding failed - log but don't crash (raw publisher still gets the message)
            #warning(
              "Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
            print("Failed to decode application context: \(error)")
          }
        }
      }
    }

    /// Handles received binary message data with reply handler.
    nonisolated public func session(
      _ session: any ConnectivitySession,
      didReceiveMessageData messageData: Data,
      replyHandler: @escaping @Sendable (Data) -> Void
    ) {
      Task { @MainActor in
        // Decode and send to typed publisher
        if let decoder = self.messageDecoder {
          do {
            let decoded = try decoder.decodeBinary(messageData)
            self.typedMessageReceived.send(decoded)
          } catch {
            // Decoding failed - log the error
            #warning(
              "Error silently swallowed - replace print() with proper logging (OSLog/Logger)")
            print("Failed to decode binary message: \(error)")
          }
        }

        // IMPORTANT: Must call reply handler to complete the send operation on sender's side
        // Send empty Data as acknowledgment since we don't have a reply payload
        replyHandler(Data())
      }
    }
  }
#endif
