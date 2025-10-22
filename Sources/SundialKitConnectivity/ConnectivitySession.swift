//
//  ConnectivitySession.swift
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

public protocol ConnectivitySession: AnyObject, Sendable {
  var delegate: (any ConnectivitySessionDelegate)? { get set }
  var isReachable: Bool { get }

  #if os(iOS)
    var isPaired: Bool { get }
  #endif
  var isPairedAppInstalled: Bool { get }
  var activationState: ActivationState { get }

  func activate() throws
  func updateApplicationContext(_ context: ConnectivityMessage) throws
  func sendMessage(
    _ message: ConnectivityMessage,
    _ completion: @escaping (Result<ConnectivityMessage, any Error>) -> Void
  )

  /// Sends binary message data to the counterpart device.
  ///
  /// This method provides direct binary transport for `BinaryMessagable` types.
  /// The binary data should include a type discrimination footer created by
  /// `BinaryMessageEncoder.encode(_:)`.
  ///
  /// - Parameters:
  ///   - data: The binary message data with type footer
  ///   - completion: Handler called with the result (reply data or error)
  func sendMessageData(
    _ data: Data,
    _ completion: @escaping (Result<Data, any Error>) -> Void
  )
}
