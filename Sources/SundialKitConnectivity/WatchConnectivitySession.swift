//
// WatchConnectivitySession.swift
// Copyright (c) 2025 BrightDigit.
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
