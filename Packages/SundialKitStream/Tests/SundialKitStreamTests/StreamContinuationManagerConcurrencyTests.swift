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

@Suite("StreamContinuationManager Concurrency Tests")
internal struct StreamContinuationManagerConcurrencyTests {
  // MARK: - Concurrent Operations Tests

  @Test("Concurrent yielding to same stream type")
  internal func concurrentYielding() async {
    let manager = StreamContinuationManager()
    let capture = TestValueCapture()

    await confirmation("All values received", expectedCount: 10) { confirm in
      let id = UUID()
      let stream = AsyncStream<ActivationState> { continuation in
        Task.detached {
          await manager.registerActivation(id: id, continuation: continuation)
        }
      }

      Task { @Sendable in
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
      try? await Task.sleep(for: .milliseconds(50))

      // Yield multiple values concurrently
      await withTaskGroup(of: Void.self) { group in
        for _ in 0..<10 {
          group.addTask {
            await manager.yieldActivationState(.activated)
          }
        }
      }
    }

    // Note: Test verifies concurrent yields are handled correctly via confirmation callback
  }

  @Test("Multiple stream types active simultaneously")
  internal func multipleStreamTypes() async {
    let manager = StreamContinuationManager()
    let activationCapture = TestValueCapture()
    let reachabilityCapture = TestValueCapture()
    let pairedAppInstalledCapture = TestValueCapture()

    await withTaskGroup(of: Void.self) { group in
      // Activation stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<ActivationState> { continuation in
          Task.detached {
            await manager.registerActivation(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await activationCapture.set(boolValue: true)
          break
        }
      }

      // Reachability stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task.detached {
            await manager.registerReachability(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await reachabilityCapture.set(boolValue: true)
          break
        }
      }

      // Paired app installed stream
      group.addTask {
        let id = UUID()
        let stream = AsyncStream<Bool> { continuation in
          Task.detached {
            await manager.registerPairedAppInstalled(id: id, continuation: continuation)
          }
        }

        for await _ in stream {
          await pairedAppInstalledCapture.set(boolValue: true)
          break
        }
      }

      // Give subscribers time to set up
      try? await Task.sleep(for: .milliseconds(100))

      // Yield to all streams
      await manager.yieldActivationState(.activated)
      await manager.yieldReachability(true)
      await manager.yieldPairedAppInstalled(true)
    }

    let activationReceived = await activationCapture.boolValue
    let reachabilityReceived = await reachabilityCapture.boolValue
    let pairedAppInstalledReceived = await pairedAppInstalledCapture.boolValue

    #expect(activationReceived == true)
    #expect(reachabilityReceived == true)
    #expect(pairedAppInstalledReceived == true)
  }
}
