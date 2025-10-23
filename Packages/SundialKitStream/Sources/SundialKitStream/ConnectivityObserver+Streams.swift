//
//  ConnectivityObserver+Streams.swift
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

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
extension ConnectivityObserver {
  // MARK: - AsyncStream APIs

  /// AsyncStream of activation state changes
  /// - Returns: Stream that yields activation states as they change
  public func activationStates() -> AsyncStream<ActivationState> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerActivation(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeActivation(id: id) },
      initialValue: { await self.stateManager.activationState }
    )
  }

  /// AsyncStream of activation completion events (with success state or error)
  /// - Returns: Stream that yields Result containing activation state or error
  public func activationCompletionStream() -> AsyncStream<Result<ActivationState, Error>> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerActivationCompletion(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeActivationCompletion(id: id) }
    )
  }

  /// AsyncStream of reachability changes
  /// - Returns: Stream that yields reachability status as it changes
  public func reachabilityUpdates() -> AsyncStream<Bool> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerReachability(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeReachability(id: id) },
      initialValue: { await self.stateManager.isReachable }
    )
  }

  /// AsyncStream of paired app installed status changes
  /// - Returns: Stream that yields paired app installed status as it changes
  public func pairedAppInstalledUpdates() -> AsyncStream<Bool> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerPairedAppInstalled(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removePairedAppInstalled(id: id) },
      initialValue: { await self.stateManager.isPairedAppInstalled }
    )
  }

  #if os(iOS)
    /// AsyncStream of paired status changes (iOS only)
    /// - Returns: Stream that yields paired status as it changes
    @available(watchOS, unavailable)
    public func pairedUpdates() -> AsyncStream<Bool> {
      AsyncStream(
        register: { id, cont in
          await self.continuationManager.registerPaired(id: id, continuation: cont)
        },
        unregister: { id in await self.continuationManager.removePaired(id: id) },
        initialValue: { await self.stateManager.isPaired }
      )
    }
  #endif

  /// AsyncStream of received messages
  /// - Returns: Stream that yields messages as they are received
  public func messageStream() -> AsyncStream<ConnectivityReceiveResult> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerMessageReceived(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeMessageReceived(id: id) }
    )
  }

  /// AsyncStream of typed decoded messages
  ///
  /// Requires a `MessageDecoder` to be configured during initialization.
  /// Both dictionary and binary messages are automatically decoded into
  /// their typed `Messagable` forms.
  ///
  /// - Returns: Stream that yields decoded messages as they are received
  public func typedMessageStream() -> AsyncStream<Messagable> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerTypedMessage(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeTypedMessage(id: id) }
    )
  }

  /// AsyncStream of send results
  /// - Returns: Stream that yields send results as messages are sent
  public func sendResultStream() -> AsyncStream<ConnectivitySendResult> {
    AsyncStream(
      register: { id, cont in
        await self.continuationManager.registerSendResult(id: id, continuation: cont)
      },
      unregister: { id in await self.continuationManager.removeSendResult(id: id) }
    )
  }
}
