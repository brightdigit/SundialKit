//
//  NeverConnectivitySession.swift
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

/// A no-op implementation of `ConnectivitySession` for platforms without WatchConnectivity.
///
/// Used on macOS and tvOS where WatchConnectivity is not available.
/// All operations throw or return inactive/unavailable states.
public final class NeverConnectivitySession: NSObject, ConnectivitySession, @unchecked Sendable {
  /// The delegate (always nil for this implementation).
  public var delegate: (any ConnectivitySessionDelegate)? {
    get {
      nil
    }
    // swiftlint:disable:next unused_setter_value
    set {}
  }

  /// Whether the counterpart is reachable (always false).
  public var isReachable: Bool {
    false
  }

  /// Whether devices are paired (always false).
  public var isPaired: Bool {
    false
  }

  /// Whether the counterpart app is installed (always false).
  public var isPairedAppInstalled: Bool {
    false
  }

  /// The activation state (always notActivated).
  public var activationState: ActivationState {
    .notActivated
  }

  /// Attempts to activate the session (always throws).
  ///
  /// - Throws: `SundialError.sessionNotSupported`
  public func activate() throws {
    throw SundialError.sessionNotSupported
  }

  /// Attempts to update application context (always throws).
  ///
  /// - Throws: `SundialError.sessionNotSupported`
  public func updateApplicationContext(_: ConnectivityMessage) throws {
    throw SundialError.sessionNotSupported
  }

  /// Attempts to send a message (always fails).
  public func sendMessage(
    _: ConnectivityMessage,
    _ completion: @escaping (Result<ConnectivityMessage, any Error>) -> Void
  ) {
    completion(.failure(SundialError.sessionNotSupported))
  }

  /// Attempts to send binary message data (always fails).
  public func sendMessageData(
    _: Data,
    _ completion: @escaping (Result<Data, any Error>) -> Void
  ) {
    completion(.failure(SundialError.sessionNotSupported))
  }
}
