//
//  WatchConnectivityTestApp.swift
//  WatchConnectivityTest
//
//  Created by Leo Dion on 3/30/22.
//

import SwiftUI

@main
struct WatchConnectivityTestApp: App {
    var body: some Scene {
        WindowGroup {
          ContentView().environmentObject(WCObject())
        }
    }
}
