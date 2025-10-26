//
//  SundialView.swift
//  Sundial
//
//  Created by Leo Dion on 5/10/22.
//

import SwiftUI

struct SundialView: View {
  var carouselWatch : some TabViewStyle {
    #if os(watchOS)
    return .page
    #else
    return .automatic
    #endif
  }
    var body: some View {
      TabView{
        #if false
        WCView().tabItem {
          Image(systemName: "applewatch.radiowaves.left.and.right")
          Text("Connectivity")
        }
        NWView().tabItem {
          Image(systemName: "network")
          Text("Network")
        }
        #else
        WatchMessagableDemoView().tabItem {
          Image(systemName: "applewatch.radiowaves.left.and.right")
          Text("Connectivity")
        }
        NetworkObserverDemoView().tabItem {
          Image(systemName: "network")
          Text("Network")
        }
        #endif
      }.tabViewStyle(.automatic)
      .environmentObject(SundailObject())
    }
}

struct SundialView_Previews: PreviewProvider {
    static var previews: some View {
        SundialView()
    }
}
