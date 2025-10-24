//
//  ConnectivityStateObserver.swift
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

  /// Protocol for observing connectivity state changes.
  ///
  /// Implement this protocol to receive notifications about changes in
  /// WatchConnectivity session state, reachability, and companion status.
  /// All delegate methods are called on the main queue.
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public protocol ConnectivityStateObserver: AnyObject {
    /// Called when the activation state changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - activationState: The new activation state
    func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeActivationState activationState: ActivationState
    )

    /// Called when reachability changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - isReachable: Whether the counterpart is now reachable
    func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeReachability isReachable: Bool
    )

    /// Called when companion app installation status changes.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - isInstalled: Whether the companion app is installed
    func connectivityManager(
      _ manager: ConnectivityManager,
      didChangeCompanionAppInstalled isInstalled: Bool
    )

    #if os(iOS)
      /// Called when the paired status changes (iOS only).
      ///
      /// - Parameters:
      ///   - manager: The connectivity manager
      ///   - isPaired: Whether an Apple Watch is paired
      func connectivityManager(
        _ manager: ConnectivityManager,
        didChangePairedStatus isPaired: Bool
      )
    #endif

    /// Called when a message is received from the counterpart.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - message: The received message
    func connectivityManager(
      _ manager: ConnectivityManager,
      didReceiveMessage message: ConnectivityMessage
    )

    /// Called when an application context update is received.
    ///
    /// - Parameters:
    ///   - manager: The connectivity manager
    ///   - context: The updated application context
    func connectivityManager(
      _ manager: ConnectivityManager,
      didReceiveApplicationContext context: ConnectivityMessage
    )
  }

  // Default implementations to make all methods optional
  extension ConnectivityStateObserver {
    public func connectivityManager(
      _: ConnectivityManager,
      didChangeActivationState _: ActivationState
    ) {}

    public func connectivityManager(
      _: ConnectivityManager,
      didChangeReachability _: Bool
    ) {}

    public func connectivityManager(
      _: ConnectivityManager,
      didChangeCompanionAppInstalled _: Bool
    ) {}

    #if os(iOS)
      public func connectivityManager(
        _: ConnectivityManager,
        didChangePairedStatus _: Bool
      ) {}
    #endif

    public func connectivityManager(
      _: ConnectivityManager,
      didReceiveMessage _: ConnectivityMessage
    ) {}

    public func connectivityManager(
      _: ConnectivityManager,
      didReceiveApplicationContext _: ConnectivityMessage
    ) {}
  }
#endif
