//
//  ConnectivityStateManagerTests+StreamReachability.swift
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

import Foundation
import Testing

@testable import SundialKitConnectivity
@testable import SundialKitCore
@testable import SundialKitStream

extension ConnectivityStateManager.Stream {
  @Suite("Reachability Tests")
  internal struct ReachabilityTests {
    @Test("Update reachability triggers reachability stream")
    internal func updateReachabilityTriggersStream() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      await confirmation("Reachability values received", expectedCount: 2) { confirm in
        let capture = TestValueCapture()

        let reachabilityStream = ConnectivityStateManager.Stream.createReachabilityStream(
          manager: continuationManager,
          id: UUID()
        )

        ConnectivityStateManager.Stream.consumeMultipleValues(
          from: reachabilityStream,
          into: capture,
          expectedCount: 2,
          confirm: confirm
        )

        // Give stream time to register
        try? await Task.sleep(for: .milliseconds(50))

        // Trigger initial activation (should emit false)
        await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

        // Give time for first notification
        try? await Task.sleep(for: .milliseconds(10))

        // Update reachability (should emit true)
        await stateManager.updateReachability(true)

        // Wait for both values to be received
        try? await Task.sleep(for: .milliseconds(100))

        let capturedValues = await capture.boolValues
        #expect(capturedValues.count == 2)
        #expect(capturedValues[0] == false)
        #expect(capturedValues[1] == true)
      }
    }
  }
}
