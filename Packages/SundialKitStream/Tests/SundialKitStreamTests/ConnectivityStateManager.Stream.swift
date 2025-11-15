//
//  ConnectivityStateManagerTests+Stream.swift
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

extension ConnectivityStateManager {
  @Suite("Stream Tests")
  internal enum Stream {
    // MARK: - Helper Functions
    // Note: Static helpers accessible to all nested suites

    internal static func createActivationStream(
      manager: SundialKitStream.StreamContinuationManager,
      id: UUID
    ) -> AsyncStream<ActivationState> {
      AsyncStream<ActivationState> { continuation in
        Task {
          await manager.registerActivation(id: id, continuation: continuation)
        }
      }
    }

    internal static func createReachabilityStream(
      manager: SundialKitStream.StreamContinuationManager,
      id: UUID
    ) -> AsyncStream<Bool> {
      AsyncStream<Bool> { continuation in
        Task {
          await manager.registerReachability(id: id, continuation: continuation)
        }
      }
    }

    internal static func createPairedAppInstalledStream(
      manager: SundialKitStream.StreamContinuationManager,
      id: UUID
    ) -> AsyncStream<Bool> {
      AsyncStream<Bool> { continuation in
        Task {
          await manager.registerPairedAppInstalled(id: id, continuation: continuation)
        }
      }
    }

    internal static func consumeSingleValue<T>(
      from stream: AsyncStream<T>,
      into capture: TestValueCapture,
      setter: @escaping @Sendable (TestValueCapture, T) async -> Void,
      confirm: Confirmation
    ) where T: Sendable {
      Task { @Sendable in
        for await value in stream {
          await setter(capture, value)
          confirm()
          break
        }
      }
    }

    internal static func consumeMultipleValues(
      from stream: AsyncStream<Bool>,
      into capture: TestValueCapture,
      expectedCount: Int,
      confirm: Confirmation
    ) {
      Task { @Sendable in
        for await value in stream {
          await capture.append(boolValue: value)
          confirm()
          let count = await capture.boolValues.count
          if count >= expectedCount {
            break
          }
        }
      }
    }
  }
}
