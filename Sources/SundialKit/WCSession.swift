import WatchConnectivity

public extension WCSession {
  var isPairedAppInstalled: Bool {
    #if os(iOS)
      return isWatchAppInstalled
    #else
      return isCompanionAppInstalled
    #endif
  }

  #if os(iOS)
    static let isCompanionAppInstalledKeyPath: KeyPath<WCSession, Bool> = \.isWatchAppInstalled
  #elseif os(watchOS)
    static let isCompanionAppInstalledKeyPath: KeyPath<WCSession, Bool> = \.isCompanionAppInstalled
  #endif
}
