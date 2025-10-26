//
//  WatchConnectivityDemoView.swift
//  Sundial
//
//  Created by Leo Dion on 10/16/22.
//

import SwiftUI
import SundialKit

class WatchConnectivityObject : ObservableObject {
  let connectivityObserver = ConnectivityObserver()
  
  @Published var isReachable : Bool = false
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
}

struct WatchConnectivityDemoView: View {
  @StateObject var connectivityObject = WatchConnectivityObject()
  var body: some View {
    Text(connectivityObject.isReachable ? "Reachable" : "Not Reachable").onAppear{
      self.connectivityObject.activate()
    }
  }
}

struct WatchConnectivityDemoView_Previews: PreviewProvider {
  static var previews: some View {
    WatchConnectivityDemoView()
  }
}
