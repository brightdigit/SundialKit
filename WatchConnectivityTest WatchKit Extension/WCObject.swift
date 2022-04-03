//
//  WCObject.swift
//  WatchConnectivityTest WatchKit Extension
//
//  Created by Leo Dion on 3/30/22.
//

import Foundation
import Combine
import WatchConnectivity
import SwiftUI

class WCObject : NSObject, WCSessionDelegate, ObservableObject {
  override init() {
    super.init()
    
    activationStateSubject.map(\.activationState).receive(on: DispatchQueue.main).assign(to: &self.$activationState)
    
    isReachableSubject.map(\.isReachable).receive(on: DispatchQueue.main).assign(to: &self.$isReachable)
        
    #if os(iOS)
    let isCompanionAppInstalledPublisher = isWatchAppInstalledSubject.map(\.isWatchAppInstalled)
    isPairedSubject.map(\.isPaired).receive(on: DispatchQueue.main).assign(to: &self.$isPaired)
    #elseif os(watchOS)
    let isCompanionAppInstalledPublisher = isiPhoneAppInstalledSubject.map(\.isCompanionAppInstalled)
    #endif
    isCompanionAppInstalledPublisher.receive(on: DispatchQueue.main).assign(to: &self.$isCompanionAppInstalled)
  }
  
  var _session : WCSession? = nil
  
  var actualSession : WCSession {
    return _session ?? WCSession.default
  }
  
  let activationStateSubject = PassthroughSubject<WCSession,Never>()
  let isReachableSubject = PassthroughSubject<WCSession,Never>()
  
  #if os(iOS)
  let isPairedSubject = PassthroughSubject<WCSession,Never>()
  let isWatchAppInstalledSubject = PassthroughSubject<WCSession,Never>()
  #elseif os(watchOS)
  let isiPhoneAppInstalledSubject = PassthroughSubject<WCSession,Never>()
  #endif
  
  #if os(iOS)
  @Published var isPaired = false
  #endif
  @Published var isReachable = false
  @Published var isCompanionAppInstalled = false
  @Published var activationState = WCSessionActivationState.notActivated
  @Published var lastColorReceived : Color?
  @Published var lastColorSent : Color?
  @Published var lastError : Error?
  
  #if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
    self.activationStateSubject.send(session)
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    self.activationStateSubject.send(session)
  }
  
  func sessionWatchStateDidChange(_ session: WCSession) {
    self.isPairedSubject.send(session)
    self.isWatchAppInstalledSubject.send(session)
  }
  #elseif os(watchOS)
  
  func sessionCompanionAppInstalledDidChange(_ session: WCSession){
    self.isiPhoneAppInstalledSubject.send(session)
  }
  #endif
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    self._session = session
  }
  
  func sessionReachabilityDidChange(_ session: WCSession) {
    self.isReachableSubject.send(session)
  }
  
  
  
  func sendColor(_ color: Color) {
    self.actualSession.sendMessage(["colorValue" : color]) { reply in
      if let colorValue = reply["colorValue"] as? Int {
        let color = Color(colorValue)
        DispatchQueue.main.async{
          [weak self] in
          self?.lastColorSent = color
        }
      }
    } errorHandler: { [weak self] error in
      self?.lastError = error
    }
  }
  
  func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    if let colorValue = message["colorValue"] as? Int {
      let color = Color(colorValue)
      replyHandler(message)
      DispatchQueue.main.async{
        [weak self] in
        self?.lastColorReceived = color
      }
    }
  }
  
  
}
