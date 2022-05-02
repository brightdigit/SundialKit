#if canImport(WatchConnectivity)
  import WatchConnectivity

  public extension WCSession {
    /// polyfill for whether the app is installed on the other device
    var isPairedAppInstalled: Bool {
      #if os(iOS)
        return isWatchAppInstalled
      #else
        return isCompanionAppInstalled
      #endif
    }
  }
#endif
