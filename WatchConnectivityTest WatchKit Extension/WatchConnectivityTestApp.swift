//
//  WatchConnectivityTestApp.swift
//  WatchConnectivityTest WatchKit Extension
//
//  Created by Leo Dion on 3/30/22.
//

import SwiftUI
import WatchConnectivity

@main
struct WatchConnectivityTestApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
              ContentView().environmentObject(WCObject())
                
            }
        }
    }
}
