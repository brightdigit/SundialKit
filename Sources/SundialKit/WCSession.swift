#if canImport(WatchConnectivity)
  import WatchConnectivity

  public extension WCSession {
    var isPairedAppInstalled: Bool {
      #if os(iOS)
        return isWatchAppInstalled
      #else
        return isCompanionAppInstalled
      #endif
    }
  }
#endif
