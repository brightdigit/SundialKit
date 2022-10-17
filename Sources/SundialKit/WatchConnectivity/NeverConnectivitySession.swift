//
//  File.swift
//  
//
//  Created by Leo Dion on 10/16/22.
//

import Foundation

internal class NeverConnectivitySession: NSObject, ConnectivitySession {
  var delegate: ConnectivitySessionDelegate? {
    get {
      return nil
    }
    set {
      
    }
  }
  
  var isReachable: Bool {
    return false
  }
  
  var isPaired: Bool {
    return false
  }
  
  var isPairedAppInstalled: Bool {
    return false
  }
  
  var activationState: ActivationState {
    return .notActivated
  }
  
  func activate() throws {
    throw SundialError.sessionNotSupported
  }
  
  func updateApplicationContext(_ context: ConnectivityMessage) throws {
    
  }
  
  func sendMessage(_ message: ConnectivityMessage, _ completion: @escaping (Result<ConnectivityMessage, Error>) -> Void) {
    
  }
  
}
