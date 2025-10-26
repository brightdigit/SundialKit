//
//  ConnectivityManagerMessagingTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  import Foundation
  import Testing

  @testable import SundialKitConnectivity
  @testable import SundialKitCore

  @Suite("ConnectivityManager Message Sending Tests")
  internal struct ConnectivityManagerMessagingTests {
    @Test("Send message when reachable succeeds")
    internal func sendMessageWhenReachableSucceeds() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.nextReplyResult = .success(["response": "ok"])

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]
      let reply = try await manager.send(message: message, replyTimeout: 5)

      #expect(mockSession.lastMessageSent?["test"] as? String == "message")
      #expect(reply["response"] as? String == "ok")
    }

    @Test("Send message falls back to updateApplicationContext when not reachable")
    internal func sendMessageFallsBackToUpdateApplicationContext() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = false
      mockSession.isPairedAppInstalled = true

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]
      let reply = try await manager.send(message: message, replyTimeout: 5)

      // Should have called updateApplicationContext
      #expect(mockSession.lastAppContext?["test"] as? String == "message")
      // Reply should be empty for context updates
      #expect(reply.isEmpty)
    }

    @Test("Send message throws when companion unavailable")
    internal func sendMessageThrowsWhenCompanionUnavailable() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = false
      mockSession.isPairedAppInstalled = false

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "message"]

      do {
        _ = try await manager.send(message: message, replyTimeout: 5)
        Issue.record("Expected send to throw when companion unavailable")
      } catch {
        #expect(error is ConnectivityError)
        if let connectivityError = error as? ConnectivityError {
          #expect(connectivityError == .companionAppNotInstalled)
        }
      }
    }

    @Test("Send message validates payload size")
    internal func sendMessageValidatesPayloadSize() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true

      let manager = ConnectivityManager(session: mockSession)

      // Create a large message that exceeds 65KB
      var largeMessage: ConnectivityMessage = [:]
      for index in 0..<10_000 {
        largeMessage["key\(index)"] = String(repeating: "x", count: 100)
      }

      do {
        _ = try await manager.send(message: largeMessage, replyTimeout: 5)
        Issue.record("Expected send to throw for oversized payload")
      } catch {
        #expect(error is ConnectivityError)
        if let connectivityError = error as? ConnectivityError {
          #expect(connectivityError == .payloadTooLarge)
        }
      }
    }

    @Test("Legacy sendMessage method works")
    internal func legacySendMessageWorks() async throws {
      let mockSession = MockSession()
      mockSession.activationState = .activated
      mockSession.isReachable = true
      mockSession.nextReplyResult = .success(["reply": "data"])

      let manager = ConnectivityManager(session: mockSession)

      let message: ConnectivityMessage = ["test": "legacy"]

      await withCheckedContinuation { continuation in
        manager.sendMessage(
          message,
          replyHandler: { reply in
            #expect(reply["reply"] as? String == "data")
            continuation.resume()
          },
          errorHandler: { error in
            Issue.record("Legacy sendMessage failed: \(error)")
            continuation.resume()
          }
        )
      }

      #expect(mockSession.lastMessageSent?["test"] as? String == "legacy")
    }
  }
#endif
