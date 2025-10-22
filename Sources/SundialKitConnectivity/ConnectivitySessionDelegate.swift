//
//  ConnectivitySessionDelegate.swift
//  SundialKit
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
public import SundialKitCore

public protocol ConnectivitySessionDelegate: AnyObject {
  func session(
    _ session: any ConnectivitySession,
    activationDidCompleteWith activationState: ActivationState,
    error: (any Error)?
  )

  func sessionDidBecomeInactive(_ session: any ConnectivitySession)

  func sessionDidDeactivate(_ session: any ConnectivitySession)

  func sessionCompanionStateDidChange(_ session: any ConnectivitySession)

  func sessionReachabilityDidChange(_ session: any ConnectivitySession)

  func session(
    _ session: any ConnectivitySession,
    didReceiveMessage message: ConnectivityMessage,
    replyHandler: @escaping ConnectivityHandler
  )

  func session(
    _ session: any ConnectivitySession,
    didReceiveApplicationContext applicationContext: ConnectivityMessage,
    error: (any Error)?
  )

  /// Called when binary message data is received from the counterpart device.
  ///
  /// This method is invoked when the session receives binary data via
  /// WatchConnectivity's `session(_:didReceiveMessageData:replyHandler:)`.
  ///
  /// The binary data includes a type discrimination footer that can be decoded
  /// using `BinaryMessageEncoder.decode(_:)` or `MessageDecoder.decodeBinary(_:)`.
  ///
  /// - Parameters:
  ///   - session: The connectivity session
  ///   - messageData: The received binary message data with type footer
  ///   - replyHandler: Handler to send binary reply data back to sender
  func session(
    _ session: any ConnectivitySession,
    didReceiveMessageData messageData: Data,
    replyHandler: @escaping @Sendable (Data) -> Void
  )
}
