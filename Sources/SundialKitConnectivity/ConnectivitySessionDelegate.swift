//
// ConnectivitySessionDelegate.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// Delegate protocol for receiving WatchConnectivity session lifecycle and message events.
///
/// Implement this protocol to receive callbacks about session activation, state changes,
/// and message delivery from a `ConnectivitySession`.
public protocol ConnectivitySessionDelegate: AnyObject {
  func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith activationState: ActivationState,
    error: (any Error)?
  )

  func sessionDidBecomeInactive(_ session: any ConnectivitySession)

  func sessionDidDeactivate(_ session: any ConnectivitySession)

  func sessionCompanionStateDidChange(_ session: any ConnectivitySession)

  func sessionReachabilityDidChange(_ session: any ConnectivitySession)

  func session(
    _ session: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping ConnectivityHandler
  )

  func session(
    _ session: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: (any Error)?
  )

  /// Called when binary message data is received from the counterpart device.
  ///
  /// This method is invoked when the session receives binary data via
  /// WatchConnectivity's `session(_:didReceiveMessageData:replyHandler:)`.
  ///
  /// The binary data includes a type discrimination footer that can be decoded
  /// using `BinaryMessageEncoder.decode(_:)` or `MessageDecoder.decodeBinary(_:)`.
  ///
  /// - Parameters:
  ///   - session: The connectivity session
  ///   - messageData: The received binary message data with type footer
  ///   - replyHandler: Handler to send binary reply data back to sender
  func session(
    _ session: any ConnectivitySession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  )
}
