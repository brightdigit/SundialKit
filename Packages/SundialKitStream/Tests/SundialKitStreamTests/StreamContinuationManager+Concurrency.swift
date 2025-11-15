//
//  StreamContinuationManagerConcurrencyTests.swift
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

extension StreamContinuationManager {
  // MARK: - Concurrent Operations Tests

  @Suite("Concurrency Tests")
  internal struct Concurrency {
    // MARK: - Helper Functions

    private static func setupAndConsumeMultipleStreamTypes(
      manager: SundialKitStream.StreamContinuationManager,
      activationCapture: TestValueCapture,
      reachabilityCapture: TestValueCapture,
      pairedAppInstalledCapture: TestValueCapture,
      confirm: Confirmation
    ) {
      // Activation stream
      Task {
        let id = UUID()
        let stream = AsyncStream<ActivationState> { continuation in
          Task {
            await manager.registerActivation(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await activationCapture.set(boolValue: true)
          confirm()
          break
        }
      }

      // Reachability stream
      Task {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task {
            await manager.registerReachability(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await reachabilityCapture.set(boolValue: true)
          confirm()
          break
        }
      }

      // Paired app installed stream
      Task {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task {
            await manager.registerPairedAppInstalled(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await pairedAppInstalledCapture.set(boolValue: true)
          confirm()
          break
        }
      }
    }

    @Test("Concurrent yielding to same stream type")
    internal func concurrentYielding() async throws {
      let manager = SundialKitStream.StreamContinuationManager()
      let id = UUID()

      let stream = AsyncStream<ActivationState> { continuation in
        Task {
          await manager.registerActivation(id: id, continuation: continuation)
        }
      }

      try await confirmation("All values received", expectedCount: 10) { confirm in
        let consumerTask = Task { @Sendable in
          var count = 0
          for await _ in stream {
            confirm()
            count += 1
            if count >= 10 {
              break
            }
          }
        }

        // Give subscriber time to set up
        try await Task.sleep(for: .milliseconds(50))

        // Yield multiple values concurrently
        await withTaskGroup(of: Void.self) { group in
          for _ in 0..<10 {
            group.addTask {
              await manager.yieldActivationState(.activated)
            }
          }
        }

        // Wait for consumer to process all values
        await consumerTask.value
      }
    }

    @Test("Multiple stream types active simultaneously")
    internal func multipleStreamTypes() async {
      let manager = SundialKitStream.StreamContinuationManager()

      await confirmation("All stream types received", expectedCount: 3) { confirm in
        let activationCapture = TestValueCapture()
        let reachabilityCapture = TestValueCapture()
        let pairedAppInstalledCapture = TestValueCapture()

        Self.setupAndConsumeMultipleStreamTypes(
          manager: manager,
          activationCapture: activationCapture,
          reachabilityCapture: reachabilityCapture,
          pairedAppInstalledCapture: pairedAppInstalledCapture,
          confirm: confirm
        )

        // Give subscribers time to set up
        try? await Task.sleep(for: .milliseconds(50))

        // Yield to all streams
        await manager.yieldActivationState(.activated)
        await manager.yieldReachability(true)
        await manager.yieldPairedAppInstalled(true)

        // Wait for all streams to receive values
        try? await Task.sleep(for: .milliseconds(100))

        let activationValue = await activationCapture.boolValue
        let reachabilityValue = await reachabilityCapture.boolValue
        let pairedAppInstalledValue = await pairedAppInstalledCapture.boolValue

        #expect(activationValue == true)
        #expect(reachabilityValue == true)
        #expect(pairedAppInstalledValue == true)
      }
    }
  }
}
