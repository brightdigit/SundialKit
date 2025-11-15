//
//  ConnectivityStateManagerTests+StreamActivation.swift
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
  @Suite("Activation Tests")
  internal struct ActivationTests {
    @Test("Handle activation triggers all stream notifications")
    internal func handleActivationTriggersNotifications() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      await confirmation("All notifications received", expectedCount: 3) { confirm in
        let capture = TestValueCapture()

        // Create streams
        let activationStream = ConnectivityStateManager.Stream.createActivationStream(
          manager: continuationManager,
          id: UUID()
        )
        let reachabilityStream = ConnectivityStateManager.Stream.createReachabilityStream(
          manager: continuationManager,
          id: UUID()
        )
        let pairedAppInstalledStream = ConnectivityStateManager.Stream
          .createPairedAppInstalledStream(
            manager: continuationManager,
            id: UUID()
          )

        // Consume streams
        ConnectivityStateManager.Stream.consumeSingleValue(
          from: activationStream,
          into: capture,
          setter: { await $0.set(activationState: $1) },
          confirm: confirm
        )
        ConnectivityStateManager.Stream.consumeSingleValue(
          from: reachabilityStream,
          into: capture,
          setter: { await $0.set(reachability: $1) },
          confirm: confirm
        )
        ConnectivityStateManager.Stream.consumeSingleValue(
          from: pairedAppInstalledStream,
          into: capture,
          setter: { await $0.set(pairedAppInstalled: $1) },
          confirm: confirm
        )

        // Give streams time to register
        try? await Task.sleep(for: .milliseconds(50))

        // Trigger activation
        session.isReachable = true
        session.isPairedAppInstalled = true
        await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

        // Wait for all streams to receive values
        try? await Task.sleep(for: .milliseconds(100))

        // Verify all notifications were triggered
        let activationState = await capture.activationState
        let reachability = await capture.reachability
        let pairedAppInstalled = await capture.pairedAppInstalled

        #expect(activationState == .activated)
        #expect(reachability == true)
        #expect(pairedAppInstalled == true)
      }
    }
  }
}
