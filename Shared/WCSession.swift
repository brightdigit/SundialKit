import WatchConnectivity

extension WCSession {
  var isPairedAppInstalled: Bool {
    #if os(iOS)
      return isWatchAppInstalled
    #else
      return isCompanionAppInstalled
    #endif
  }
}
