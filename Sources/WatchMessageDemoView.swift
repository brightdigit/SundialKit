//
//  WatchConnectivityDemoView.swift
//  Sundial
//
//  Created by Leo Dion on 10/16/22.
//

import SwiftUI
import SundialKit

class WatchMessageObject : ObservableObject {
  private let connectivityObserver = ConnectivityObserver()
  
  @Published var isReachable : Bool = false
  @Published var lastReceivedMessage : String = ""
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
    connectivityObserver.messageReceivedPublisher.compactMap({ (message, _) in
      message["message"] as? String
    }).receive(on: DispatchQueue.main).assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
  
  func sendMessage(_ message: String) {
    self.connectivityObserver.sendingMessageSubject.send(["message" : message])
  }
}



struct WatchMessageDemoView: View {
  @StateObject var connectivityObject = WatchMessageObject()
  @State var message : String = ""
  var body: some View {
    VStack{
      Text(connectivityObject.isReachable ? "Reachable" : "Not Reachable").onAppear{
        self.connectivityObject.activate()
      }
      TextField("Message", text: self.$message)
      Button("Send") {
        self.connectivityObject.sendMessage(self.message)
      }
      
      Text("Last received message:")
      Text(self.connectivityObject.lastReceivedMessage)
    }
  }
}

struct WatchMessageDemoView_Previews: PreviewProvider {
  static var previews: some View {
    WatchConnectivityDemoView()
  }
}
