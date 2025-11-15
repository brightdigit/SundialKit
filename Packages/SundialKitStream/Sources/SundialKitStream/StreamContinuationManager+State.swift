//
//  StreamContinuationManager+State.swift
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

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension StreamContinuationManager {
  // MARK: - Reachability Registration & Removal

  internal func registerReachability(
    id: UUID,
    continuation: AsyncStream<Bool>.Continuation
  ) {
    assert(
      reachabilityContinuations[id] == nil,
      "Duplicate continuation registration for reachability stream with ID: \(id)"
    )
    reachabilityContinuations[id] = continuation
  }

  internal func removeReachability(id: UUID) {
    assert(
      reachabilityContinuations[id] != nil,
      "Attempting to remove non-existent reachability continuation with ID: \(id)"
    )
    reachabilityContinuations.removeValue(forKey: id)
  }

  // MARK: - Paired App Installed Registration & Removal

  internal func registerPairedAppInstalled(
    id: UUID,
    continuation: AsyncStream<Bool>.Continuation
  ) {
    assert(
      pairedAppInstalledContinuations[id] == nil,
      "Duplicate continuation registration for paired app installed stream with ID: \(id)"
    )
    pairedAppInstalledContinuations[id] = continuation
  }

  internal func removePairedAppInstalled(id: UUID) {
    assert(
      pairedAppInstalledContinuations[id] != nil,
      "Attempting to remove non-existent paired app installed continuation with ID: \(id)"
    )
    pairedAppInstalledContinuations.removeValue(forKey: id)
  }

  // MARK: - Paired Registration & Removal

  internal func registerPaired(
    id: UUID,
    continuation: AsyncStream<Bool>.Continuation
  ) {
    assert(
      pairedContinuations[id] == nil,
      "Duplicate continuation registration for paired stream with ID: \(id)"
    )
    pairedContinuations[id] = continuation
  }

  internal func removePaired(id: UUID) {
    assert(
      pairedContinuations[id] != nil,
      "Attempting to remove non-existent paired continuation with ID: \(id)"
    )
    pairedContinuations.removeValue(forKey: id)
  }

  // MARK: - State Yielding

  internal func yieldReachability(_ isReachable: Bool) {
    for continuation in reachabilityContinuations.values {
      continuation.yield(isReachable)
    }
  }

  internal func yieldPairedAppInstalled(_ isPairedAppInstalled: Bool) {
    for continuation in pairedAppInstalledContinuations.values {
      continuation.yield(isPairedAppInstalled)
    }
  }

  internal func yieldPaired(_ isPaired: Bool) {
    for continuation in pairedContinuations.values {
      continuation.yield(isPaired)
    }
  }
}
