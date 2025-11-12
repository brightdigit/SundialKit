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

  private var activationContinuations: [UUID: AsyncStream<ActivationState>.Continuation] = [:]
  private var activationCompletionContinuations:
    [UUID: AsyncStream<Result<ActivationState, any Error>>.Continuation] = [:]
  private var reachabilityContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var pairedAppInstalledContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var pairedContinuations: [UUID: AsyncStream<Bool>.Continuation] = [:]
  private var messageReceivedContinuations:
    [UUID: AsyncStream<ConnectivityReceiveResult>.Continuation] = [:]
  private var typedMessageContinuations: [UUID: AsyncStream<any Messagable>.Continuation] = [:]
  private var sendResultContinuations: [UUID: AsyncStream<ConnectivitySendResult>.Continuation] =
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

  internal func registerMessageReceived(
    id: UUID,
    continuation: AsyncStream<ConnectivityReceiveResult>.Continuation
  ) {
    assert(
      messageReceivedContinuations[id] == nil,
      "Duplicate continuation registration for message received stream with ID: \(id)"
    )
    messageReceivedContinuations[id] = continuation
  }

  internal func registerTypedMessage(
    id: UUID,
    continuation: AsyncStream<any Messagable>.Continuation
  ) {
    assert(
      typedMessageContinuations[id] == nil,
      "Duplicate continuation registration for typed message stream with ID: \(id)"
    )
    typedMessageContinuations[id] = continuation
  }

  internal func registerSendResult(
    id: UUID,
    continuation: AsyncStream<ConnectivitySendResult>.Continuation
  ) {
    assert(
      sendResultContinuations[id] == nil,
      "Duplicate continuation registration for send result stream with ID: \(id)"
    )
    sendResultContinuations[id] = continuation
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

  internal func removeReachability(id: UUID) {
    assert(
      reachabilityContinuations[id] != nil,
      "Attempting to remove non-existent reachability continuation with ID: \(id)"
    )
    reachabilityContinuations.removeValue(forKey: id)
  }

  internal func removePairedAppInstalled(id: UUID) {
    assert(
      pairedAppInstalledContinuations[id] != nil,
      "Attempting to remove non-existent paired app installed continuation with ID: \(id)"
    )
    pairedAppInstalledContinuations.removeValue(forKey: id)
  }

  internal func removePaired(id: UUID) {
    assert(
      pairedContinuations[id] != nil,
      "Attempting to remove non-existent paired continuation with ID: \(id)"
    )
    pairedContinuations.removeValue(forKey: id)
  }

  internal func removeMessageReceived(id: UUID) {
    assert(
      messageReceivedContinuations[id] != nil,
      "Attempting to remove non-existent message received continuation with ID: \(id)"
    )
    messageReceivedContinuations.removeValue(forKey: id)
  }

  internal func removeTypedMessage(id: UUID) {
    assert(
      typedMessageContinuations[id] != nil,
      "Attempting to remove non-existent typed message continuation with ID: \(id)"
    )
    typedMessageContinuations.removeValue(forKey: id)
  }

  internal func removeSendResult(id: UUID) {
    assert(
      sendResultContinuations[id] != nil,
      "Attempting to remove non-existent send result continuation with ID: \(id)"
    )
    sendResultContinuations.removeValue(forKey: id)
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

  internal func yieldMessageReceived(_ result: ConnectivityReceiveResult) {
    for continuation in messageReceivedContinuations.values {
      continuation.yield(result)
    }
  }

  internal func yieldTypedMessage(_ message: any Messagable) {
    for continuation in typedMessageContinuations.values {
      continuation.yield(message)
    }
  }

  internal func yieldSendResult(_ result: ConnectivitySendResult) {
    for continuation in sendResultContinuations.values {
      continuation.yield(result)
    }
  }
}
