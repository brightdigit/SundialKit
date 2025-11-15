//
//  StreamContinuationManager+Messages.swift
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
import SundialKitConnectivity
import SundialKitCore

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension StreamContinuationManager {
  // MARK: - Message Received Registration & Removal

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

  internal func removeMessageReceived(id: UUID) {
    assert(
      messageReceivedContinuations[id] != nil,
      "Attempting to remove non-existent message received continuation with ID: \(id)"
    )
    messageReceivedContinuations.removeValue(forKey: id)
  }

  // MARK: - Typed Message Registration & Removal

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

  internal func removeTypedMessage(id: UUID) {
    assert(
      typedMessageContinuations[id] != nil,
      "Attempting to remove non-existent typed message continuation with ID: \(id)"
    )
    typedMessageContinuations.removeValue(forKey: id)
  }

  // MARK: - Send Result Registration & Removal

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

  internal func removeSendResult(id: UUID) {
    assert(
      sendResultContinuations[id] != nil,
      "Attempting to remove non-existent send result continuation with ID: \(id)"
    )
    sendResultContinuations.removeValue(forKey: id)
  }

  // MARK: - Message Yielding

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
