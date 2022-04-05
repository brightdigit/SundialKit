//
//  WCObject.swift
//  WatchConnectivityTest WatchKit Extension
//
//  Created by Leo Dion on 3/30/22.
//

import Combine
import Foundation
import SwiftUI
import WatchConnectivity

class WCObject: NSObject, WCSessionDelegate, ObservableObject {
  struct NotSupportedError : Error {}
  
  public func forceActivate () {
    try! self.activate()
  }
  public func activate () throws {
    guard WCSession.isSupported() else {
      throw NotSupportedError()
    }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    
  }
    override init() {
        super.init()

        activationStateSubject.map(\.activationState).receive(on: DispatchQueue.main).assign(to: &$activationState)

        isReachableSubject.map(\.isReachable).receive(on: DispatchQueue.main).assign(to: &$isReachable)

        #if os(iOS)
            let isCompanionAppInstalledPublisher = isWatchAppInstalledSubject.map(\.isWatchAppInstalled)
            isPairedSubject.map(\.isPaired).receive(on: DispatchQueue.main).assign(to: &$isPaired)
        #elseif os(watchOS)
            let isCompanionAppInstalledPublisher = isiPhoneAppInstalledSubject.map(\.isCompanionAppInstalled)
        #endif
        isCompanionAppInstalledPublisher.receive(on: DispatchQueue.main).assign(to: &$isCompanionAppInstalled)
    }

    var _session: WCSession?

    var actualSession: WCSession {
        return _session ?? WCSession.default
    }

    let activationStateSubject = PassthroughSubject<WCSession, Never>()
    let isReachableSubject = PassthroughSubject<WCSession, Never>()

    #if os(iOS)
        let isPairedSubject = PassthroughSubject<WCSession, Never>()
        let isWatchAppInstalledSubject = PassthroughSubject<WCSession, Never>()
    #elseif os(watchOS)
        let isiPhoneAppInstalledSubject = PassthroughSubject<WCSession, Never>()
    #endif

    #if os(iOS)
        @Published var isPaired = false
    #endif
    @Published var isReachable = false
    @Published var isCompanionAppInstalled = false
    @Published var activationState = WCSessionActivationState.notActivated
    @Published var lastColorReceived: Color?
    @Published var lastColorSent: Color?
    @Published var lastError: Error?

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {
            activationStateSubject.send(session)
        }

        func sessionDidDeactivate(_ session: WCSession) {
            activationStateSubject.send(session)
        }

        func sessionWatchStateDidChange(_ session: WCSession) {
            isPairedSubject.send(session)
            isWatchAppInstalledSubject.send(session)
        }

    #elseif os(watchOS)

        func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
            isiPhoneAppInstalledSubject.send(session)
        }
    #endif

    func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
        _session = session
        activationStateSubject.send(session)

        isReachableSubject.send(session)
        #if os(iOS)
            isWatchAppInstalledSubject.send(session)
            isPairedSubject.send(session)
        #elseif os(watchOS)
            isiPhoneAppInstalledSubject.send(session)
        #endif
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        isReachableSubject.send(session)
    }

    func sendColor(_ color: Color) {
        #if targetEnvironment(simulator)
            let color = Color(color.value!)

            DispatchQueue.main.async {
                self.lastColorSent = color
            }
        #else
            actualSession.sendMessage(["colorValue": color.value!]) { reply in
                if let colorValue = reply["colorValue"] as? Int {
                    let color = Color(colorValue)
                    DispatchQueue.main.async {
                        [weak self] in
                            self?.lastColorSent = color
                    }
                }
            } errorHandler: { [weak self] error in
                DispatchQueue.main.async {
                    self?.lastError = error
                }
            }
        #endif
    }

    func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let colorValue = message["colorValue"] as? Int {
            let color = Color(colorValue)
            replyHandler(message)
            DispatchQueue.main.async {
                [weak self] in
                    self?.lastColorReceived = color
            }
        }
    }
}
