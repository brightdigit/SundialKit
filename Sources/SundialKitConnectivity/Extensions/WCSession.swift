//
// WCSession.swift
// Copyright (c) 2025 BrightDigit.
//

#if canImport(WatchConnectivity)
  public import WatchConnectivity

  extension WCSession {
    /// polyfill for whether the app is installed on the other device
    public var isPairedAppInstalled: Bool {
      #if os(iOS) || os(visionOS)
        return isWatchAppInstalled
      #else
        return isCompanionAppInstalled
      #endif
    }
  }
#endif
