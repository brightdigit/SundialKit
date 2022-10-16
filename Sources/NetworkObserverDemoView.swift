//
//  NetworkObserverView.swift
//  Sundial
//
//  Created by Leo Dion on 10/16/22.
//

import SwiftUI
import SundialKit

class NetworkConnectivityObject : ObservableObject {
  let connectivityObserver = NetworkObserver()
  
  @Published var pathStatus : PathStatus = .unknown
  init () {
    connectivityObserver.pathStatusPublisher.receive(on: DispatchQueue.main).assign(to: &self.$pathStatus)
  }
  
  func start () {
    self.connectivityObserver.start(queue: .global())
  }
}

struct NetworkObserverDemoView: View {
  @StateObject var connectivityObject = NetworkConnectivityObject()
    var body: some View {
      Text(self.connectivityObject.pathStatus.message).onAppear{
        self.connectivityObject.start()
      }
    }
}

struct NetworkObserverView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkObserverDemoView()
    }
}
