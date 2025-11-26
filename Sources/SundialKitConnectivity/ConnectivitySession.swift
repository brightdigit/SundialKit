//
// ConnectivitySession.swift
// Copyright (c) 2025 BrightDigit.
//

public import Foundation
public import SundialKitCore

/// Protocol abstraction over Apple's WatchConnectivity framework.
///
/// Provides a Sendable-safe interface for managing communication between
/// iOS and watchOS counterpart devices, including message exchange and
/// session lifecycle management.
public protocol ConnectivitySession: AnyObject, Sendable {
  var delegate: (any ConnectivitySessionDelegate)? { get set }
  var isReachable: Bool { get }

  var isPaired: Bool { get }
  var isPairedAppInstalled: Bool { get }
  var activationState: ActivationState { get }

  /// The most recent application context received from the counterpart device.
  ///
  /// This property contains the latest context dictionary sent via `updateApplicationContext(_:)`,
  /// even if it arrived while the app was inactive. Returns `nil` if no context has been received
  /// or if the context dictionary is empty.
  var receivedApplicationContext: ConnectivityMessage? { get }

  func activate() throws
  func updateApplicationContext(_ context: ConnectivityMessage) throws
  func sendMessage(
    _ message: ConnectivityMessage,
    _ completion: @escaping (Result<ConnectivityMessage, any Error>) -> Void
  )

  /// Sends binary message data to the counterpart device.
  ///
  /// This method provides direct binary transport for `BinaryMessagable` types.
  /// The binary data should include a type discrimination footer created by
  /// `BinaryMessageEncoder.encode(_:)`.
  ///
  /// - Parameters:
  ///   - data: The binary message data with type footer
  ///   - completion: Handler called with the result (reply data or error)
  func sendMessageData(
    _ data: Data,
    _ completion: @escaping (Result<Data, any Error>) -> Void
  )
}
