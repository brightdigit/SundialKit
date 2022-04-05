//
//  PreviewContentView.swift
//  WatchConnectivityTest
//
//  Created by Leo Dion on 4/5/22.
//

import SwiftUI

struct PreviewContentView: View {
    var body: some View {
        ContentView().environmentObject(WCObject())
    }
}

struct PreviewContentView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContentView()
    }
}
