import SwiftUI

@main
struct WatchConnectivityTestApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView().environmentObject(WCObject())
    }
  }
}
