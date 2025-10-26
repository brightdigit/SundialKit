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

import Combine
class WatchMessagableObject : ObservableObject {
  private let connectivityObserver = ConnectivityObserver()
  private let messageDecoder = MessageDecoder(messagableTypes: [Message.self])
  
  @Published var isReachable : Bool = false
  @Published var lastReceivedMessage : String = ""
  @Published var lastReplyMessage : String = ""
  @Published var canReply : Bool = false
  var lastReply : ConnectivityHandler?
  var cancellable : AnyCancellable!
  init () {
    connectivityObserver.isReachablePublisher.receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
    let messageReceivedPublisher = connectivityObserver.messageReceivedPublisher
      .share()
    self.cancellable = messageReceivedPublisher.map(\.context).map(\.replyHandler).sink { handler in
      self.canReply = handler != nil
      self.lastReply = handler
    }
    self.connectivityObserver.replyMessagePublisher.map(\.message).compactMap(self.messageDecoder.decode(_:)).compactMap{$0 as? Message}.map(\.text).receive(on: DispatchQueue.main).assign(to: &self.$lastReplyMessage)
    messageReceivedPublisher
      .map(\.message)
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
  
  func replyMessage(_ message: String) {
    self.lastReply?(Message(text: message).message())
    self.lastReply = nil
    self.canReply = false
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
      Button("Reply") {
        self.connectivityObject.replyMessage(self.message)
      }.disabled(!self.connectivityObject.canReply)
      Text("Last received message:")
      Text(self.connectivityObject.lastReceivedMessage)
      Text("Last reply message:")
      Text(self.connectivityObject.lastReplyMessage)
    }
  }
}

struct WatchMessagableDemoView_Previews: PreviewProvider {
  static var previews: some View {
    WatchConnectivityDemoView()
  }
}
