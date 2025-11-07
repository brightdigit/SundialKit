//
//  LatencyResponderService.swift
//  Sundial
//
//  Created on 11/7/25.
//  Copyright (c) 2025 BrightDigit.
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

import Foundation
import SundialDemoShared
import SundialKitStream

/// App-level service that automatically responds to latency test requests.
///
/// This service runs independently of any UI tab and ensures that both devices
/// can measure latency by automatically replying to incoming LatencyTestRequest messages.
@available(iOS 17.0, watchOS 10.0, macOS 14.0, *)
public actor LatencyResponderService {
  // MARK: - Properties

  private let connectivityObserver: ConnectivityObserver
  private var listenerTask: Task<Void, Never>?

  // MARK: - Initialization

  public init(connectivityObserver: ConnectivityObserver) {
    self.connectivityObserver = connectivityObserver

    // Start listening in a detached task since init is not async
    Task {
      await self.startListening()
    }
  }

  deinit {
    listenerTask?.cancel()
  }

  // MARK: - Message Handling

  /// Start listening for incoming latency test requests.
  private func startListening() {
    listenerTask = Task {
      print("🎯 LatencyResponderService: Started listening for latency requests")

      for await message in await connectivityObserver.typedMessageStream() {
        // Filter for LatencyTestRequest messages
        if let request = message as? Sundial_Demo_LatencyTestRequest {
          await handleLatencyRequest(request)
        }
      }

      print("🎯 LatencyResponderService: Stopped listening (stream ended)")
    }
  }

  /// Handle an incoming latency test request by sending back a reply.
  private func handleLatencyRequest(_ request: Sundial_Demo_LatencyTestRequest) async {
    let receiveTime = Date()

    // Create reply using the helper method from LatencyTestReplyExtensions
    let reply = Sundial_Demo_LatencyTestReply.create(
      from: request,
      receiveTime: receiveTime,
      processingTimeUs: 0
    )

    do {
      // Send the reply back
      _ = try await connectivityObserver.send(reply)
      print("✅ LatencyResponderService: Auto-replied to latency ping #\(request.sequenceNumber)")
    } catch {
      print("❌ LatencyResponderService: Failed to send latency reply #\(request.sequenceNumber): \(error)")
    }
  }
}
