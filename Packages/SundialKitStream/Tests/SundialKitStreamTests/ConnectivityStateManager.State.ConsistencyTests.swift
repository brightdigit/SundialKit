//
//  ConnectivityStateManager.State.ConsistencyTests.swift
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

extension ConnectivityStateManager.State {
  @Suite("Consistency Tests")
  internal struct ConsistencyTests {
    @Test("State snapshot is consistent across all properties")
    internal func stateSnapshotConsistency() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      // Set up complete session state
      session.activationState = .activated
      session.isReachable = true
      session.isPairedAppInstalled = true
      session.isPaired = true

      await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

      let state = await stateManager.currentState

      // All properties should match session state
      #expect(state.activationState == .activated)
      #expect(state.activationError == nil)
      #expect(state.isReachable == true)
      #expect(state.isPairedAppInstalled == true)
      #if os(iOS)
        #expect(state.isPaired == true)
      #else
        #expect(state.isPaired == false)
      #endif
    }
  }
}
