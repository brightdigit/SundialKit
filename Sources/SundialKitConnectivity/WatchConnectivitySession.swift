//
//  WatchConnectivitySession.swift
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
  import WatchConnectivity

  /// Concrete implementation of `ConnectivitySession` wrapping Apple's `WCSession`.
  ///
  /// Provides a Sendable-safe bridge between WatchConnectivity's delegate-based API
  /// and the protocol-oriented `ConnectivitySession` interface.
  ///
  /// ## Thread Safety
  ///
  /// This class uses `@unchecked Sendable` with `NSLock` for synchronization. This is safe because:
  /// - The `session` property is immutable (let)
  /// - The mutable `delegate` property is protected by `delegateLock`
  /// - All delegate accesses acquire the lock before reading/writing
  /// - WCSession callbacks are thread-safe through proper locking
  public final class WatchConnectivitySession: NSObject, WatchConnectivitySessionProtocol,
    @unchecked Sendable
  {
    internal let session: WCSession
    #warning("replace with a property wrapper or internal actor")
    private let delegateLock = NSLock()
    // Backing storage for thread-safe delegate property with NSLock synchronization
    private var storedDelegate: ConnectivitySessionDelegate?

    /// The delegate to receive session lifecycle and message events.
    public var delegate: ConnectivitySessionDelegate? {
      get {
        delegateLock.lock()
        defer { delegateLock.unlock() }
        return storedDelegate
      }
      set {
        delegateLock.lock()
        defer { delegateLock.unlock() }
        storedDelegate = newValue
      }
    }

    internal init(session: WCSession) {
      self.session = session
      super.init()
      session.delegate = self
    }

    override public convenience init() {
      self.init(session: .default)
    }
  }

#endif
