//
//  WatchConnectivityDemoView.swift
//  Sundial
//
//  Created by Leo Dion on 10/16/22.
//

import SwiftUI
import SundialKit

struct Message : Messagable {
  internal init(text: String) {
    self.text = text
  }
  
  static let key: String = "_message"
  
  enum Parameters : String {
    case text
  }
  
  init?(from parameters: [String : Any]?) {
    guard let text = parameters?[Parameters.text.rawValue] as? String else {
      return nil
    }
    
    self.text = text
  }
  
  func parameters() -> [String : Any] {
    return [
      Parameters.text.rawValue : self.text
    ]
  }
  
  let text : String
}

class WatchMessagableObject : ObservableObject {
  private let connectivityObserver = ConnectivityObserver()
  private let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
  
  @Published var isReachable : Bool = false
  @Published var lastReceivedMessage : String = ""
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
    connectivityObserver.messageReceivedPublisher
      .map(\.0)
      .compactMap(self.messageDecoder.decode)
      .compactMap{$0 as? Message}
      .map(\.text)
      .receive(on: DispatchQueue.main)
      .assign(to: &self.$lastReceivedMessage)
  }
  
  func activate () {
    try! self.connectivityObserver.activate()
  }
  
  func sendMessage(_ message: String) {
    self.connectivityObserver.sendingMessageSubject.send(Message(text: message).message())
  }
}



struct WatchMessagableDemoView: View {
  @StateObject var connectivityObject = WatchMessagableObject()
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

struct WatchMessagableDemoView_Previews: PreviewProvider {
  static var previews: some View {
    WatchConnectivityDemoView()
  }
}
