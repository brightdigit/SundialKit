//
//  ConnectivityStateManager.State.PropertyTests.swift
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
  @Suite("Property Tests")
  internal struct PropertyTests {
    @Test("activationState getter returns correct value")
    internal func activationStateGetter() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

      let activationState = await stateManager.activationState
      #expect(activationState == .activated)
    }

    @Test("activationError getter returns correct value")
    internal func activationErrorGetter() async {
      struct TestError: Error, Sendable {}

      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      await stateManager.handleActivation(
        from: session,
        activationState: .inactive,
        error: TestError()
      )

      let activationError = await stateManager.activationError
      #expect(activationError is TestError)
    }

    @Test("isReachable getter returns correct value")
    internal func isReachableGetter() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      session.isReachable = true
      await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

      let isReachable = await stateManager.isReachable
      #expect(isReachable == true)
    }

    @Test("isPairedAppInstalled getter returns correct value")
    internal func isPairedAppInstalledGetter() async {
      let continuationManager = SundialKitStream.StreamContinuationManager()
      let stateManager = SundialKitStream.ConnectivityStateManager(
        continuationManager: continuationManager
      )
      let session = MockConnectivitySession()

      session.isPairedAppInstalled = true
      await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

      let isPairedAppInstalled = await stateManager.isPairedAppInstalled
      #expect(isPairedAppInstalled == true)
    }

    #if os(iOS)
      @Test("isPaired getter returns correct value on iOS")
      internal func isPairedGetter() async {
        let continuationManager = SundialKitStream.StreamContinuationManager()
        let stateManager = SundialKitStream.ConnectivityStateManager(
          continuationManager: continuationManager
        )
        let session = MockConnectivitySession()

        session.isPaired = true
        await stateManager.handleActivation(from: session, activationState: .activated, error: nil)

        let isPaired = await stateManager.isPaired
        #expect(isPaired == true)
      }
    #endif
  }
}
