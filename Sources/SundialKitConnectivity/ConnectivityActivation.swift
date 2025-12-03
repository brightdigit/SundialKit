//
//  ConnectivityActivation.swift
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

#if canImport(WatchConnectivity)
  public import Foundation
  public import SundialKitCore

  /// Protocol for types that support connectivity session activation.
  ///
  /// This protocol defines the interface for activating connectivity sessions,
  /// including both synchronous and asynchronous activation patterns with timeout support.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityActivation {
    /// The underlying connectivity session.
    nonisolated var session: any ConnectivitySession { get }

    /// The current activation state of the connectivity session.
    var activationState: ActivationState { get async }

    /// Storage for activation continuation during async activation.
    var activationContinuation: CheckedContinuation<Void, any Error>? { get async }

    /// Storage for activation timeout task.
    var activationTimeoutTask: Task<Void, Never>? { get async }

    /// Activates the connectivity session synchronously.
    ///
    /// - Throws: `ConnectivityError` if activation fails.
    func activate() throws

    /// Sets the activation continuation.
    ///
    /// - Parameter continuation: The continuation to store.
    func setActivationContinuation(_ continuation: CheckedContinuation<Void, any Error>) async

    /// Sets the activation timeout task.
    ///
    /// - Parameter task: The timeout task to store.
    func setActivationTimeoutTask(_ task: Task<Void, Never>) async

    /// Handles activation timeout by resuming the stored continuation with an error.
    func handleActivationTimeout() async

    /// Handles activation errors by resuming the stored continuation.
    ///
    /// - Parameter error: The error that occurred during activation.
    func handleActivationError(_ error: any Error) async
  }
#endif
