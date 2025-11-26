//
// ConnectivityMessaging+Actor.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  public import SundialKitCore
  import WatchConnectivity

  // MARK: - Default Implementations for Actor-Based Messaging

  extension ConnectivityMessaging where Self: Actor {
    /// Sends a message to the counterpart device.
    ///
    /// This method provides actor-isolated access to messaging.
    ///
    /// - Parameters:
    ///   - message: The message dictionary to send.
    ///   - replyHandler: Called when a reply is received.
    ///   - errorHandler: Called if sending fails.
    public func sendMessage(
      _ message: ConnectivityMessage,
      replyHandler: @escaping (ConnectivityMessage) -> Void,
      errorHandler: @escaping (any Error) -> Void
    ) {
      session.sendMessage(message) { result in
        switch result {
        case .success(let reply):
          replyHandler(reply)
        case .failure(let error):
          errorHandler(error)
        }
      }
    }

    /// Updates the application context.
    ///
    /// This method provides actor-isolated access to context updates.
    ///
    /// - Parameter context: The context dictionary to send.
    /// - Throws: `ConnectivityError` if the update fails.
    public func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context)
    }
  }
#endif
