//
// SlowMockSession.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  /// Mock session that doesn't auto-activate to test slow activation scenarios.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  internal final class SlowMockSession: ConnectivitySession, @unchecked Sendable {
    var receivedApplicationContext: SundialKitCore.ConnectivityMessage? {
      lastAppContext
    }

    internal var lastMessageSent: ConnectivityMessage?
    internal var lastAppContext: ConnectivityMessage?
    internal var nextReplyResult: Result<ConnectivityMessage, any Error>?
    internal var nextApplicationContextError: (any Error)?
    internal var isPaired = false
    internal var delegate: (any ConnectivitySessionDelegate)?
    internal var isReachable = false
    internal var isPairedAppInstalled = false

    internal var activationState: ActivationState = .notActivated {
      didSet {
        delegate?.session(self, activationDidCompleteWith: activationState, error: nil)
      }
    }

    internal func activate() throws {
      // Don't automatically change state - tests will do this manually
    }

    internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
      if let nextApplicationContextError = nextApplicationContextError {
        throw nextApplicationContextError
      }
      lastAppContext = context
    }

    internal func sendMessage(
      _ message: ConnectivityMessage,
      _ replyHandler: @escaping (Result<ConnectivityMessage, any Error>) -> Void
    ) {
      lastMessageSent = message
      replyHandler(nextReplyResult ?? .success([:]))
    }

    internal func sendMessageData(
      _ data: Data,
      _ completion: @escaping (Result<Data, any Error>) -> Void
    ) {
      completion(.success(Data()))
    }
  }
#endif
