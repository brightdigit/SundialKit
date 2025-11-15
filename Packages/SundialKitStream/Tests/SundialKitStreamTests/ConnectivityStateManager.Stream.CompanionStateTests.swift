//
//  ConnectivityStateManagerTests+StreamCompanion.swift
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
  @Suite("Companion State Tests")
  internal struct CompanionStateTests {
    @Test("Update companion state triggers paired app installed stream")
    internal func updateCompanionStateTriggersStream() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )

      await confirmation("Paired app installed received", expectedCount: 1) { confirm in
        let capture = TestValueCapture()

        let pairedAppInstalledStream = ConnectivityStateManager.Stream
          .createPairedAppInstalledStream(
            manager: continuationManager,
            id: UUID()
          )

        ConnectivityStateManager.Stream.consumeSingleValue(
          from: pairedAppInstalledStream,
          into: capture,
          setter: { await $0.set(pairedAppInstalled: $1) },
          confirm: confirm
        )

        // Give stream time to register
        try? await Task.sleep(for: .milliseconds(50))

        // Update companion state
        await stateManager.updateCompanionState(isPairedAppInstalled: true, isPaired: false)

        // Wait for stream to receive value
        try? await Task.sleep(for: .milliseconds(100))

        let capturedValue = await capture.pairedAppInstalled
        #expect(capturedValue == true)
      }
    }
  }
}
