//
//  StreamContinuationManager.swift
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

public import Foundation
public import SundialKitConnectivity
public import SundialKitCore

/// Manages AsyncStream continuations for ConnectivityObserver
///
/// This type centralizes all continuation management, providing
/// registration, removal, and yielding capabilities for all stream types.
@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
internal actor StreamContinuationManager {
  // MARK: - Continuation Storage

  internal var activationContinuations: [UUID: AsyncStream<ActivationState>.Continuation] = [:]
  internal var activationCompletionContinuations:
    [UUID: AsyncStream<Result<ActivationState, any Error>>.Continuation] = [:]
  internal var reachabilityContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  internal var pairedAppInstalledContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  internal var pairedContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  internal var messageReceivedContinuations:
    [UUID: AsyncStream<ConnectivityReceiveResult>.Continuation] = [:]
  internal var typedMessageContinuations: [UUID: AsyncStream<any Messagable>.Continuation] = [:]
  internal var sendResultContinuations: [UUID: AsyncStream<ConnectivitySendResult>.Continuation] =
    [:]

  // MARK: - Registration

  internal func registerActivation(
    id: UUID,
    continuation: AsyncStream<ActivationState>.Continuation
  ) {
    assert(
      activationContinuations[id] == nil,
      "Duplicate continuation registration for activation stream with ID: \(id)"
    )
    activationContinuations[id] = continuation
  }

  internal func registerActivationCompletion(
    id: UUID,
    continuation: AsyncStream<Result<ActivationState, any Error>>.Continuation
  ) {
    assert(
      activationCompletionContinuations[id] == nil,
      "Duplicate continuation registration for activation completion stream with ID: \(id)"
    )
    activationCompletionContinuations[id] = continuation
  }

  // MARK: - Removal

  internal func removeActivation(id: UUID) {
    assert(
      activationContinuations[id] != nil,
      "Attempting to remove non-existent activation continuation with ID: \(id)"
    )
    activationContinuations.removeValue(forKey: id)
  }

  internal func removeActivationCompletion(id: UUID) {
    assert(
      activationCompletionContinuations[id] != nil,
      "Attempting to remove non-existent activation completion continuation with ID: \(id)"
    )
    activationCompletionContinuations.removeValue(forKey: id)
  }

  // MARK: - Yielding Values

  internal func yieldActivationState(_ state: ActivationState) {
    for continuation in activationContinuations.values {
      continuation.yield(state)
    }
  }

  internal func yieldActivationCompletion(_ result: Result<ActivationState, any Error>) {
    for continuation in activationCompletionContinuations.values {
      continuation.yield(result)
    }
  }
}
