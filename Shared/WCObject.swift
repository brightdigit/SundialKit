import Combine
import Foundation
import SwiftUI
import WatchConnectivity

class WCObject: NSObject, WCSessionDelegate, ObservableObject {
  struct NotSupportedError: Error {}
  var cancellable: AnyCancellable!

  public func activate() throws {
    guard WCSession.isSupported() else {
      throw NotSupportedError()
    }
    let session = WCSession.default
    session.delegate = self
    session.activate()
  }

  override init() {
    super.init()
    cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
  }

  var _session: WCSession?

  var actualSession: WCSession {
    _session ?? WCSession.default
  }

  let activationStateSubject = PassthroughSubject<WCSession, Never>()
  let isReachableSubject = PassthroughSubject<WCSession, Never>()

  let isCompanionInstalledSubject = PassthroughSubject<WCSession, Never>()
  #if os(iOS)
    let isPairedSubject = PassthroughSubject<WCSession, Never>()
  #endif

  let messageReceivedSubject = PassthroughSubject<WCMessageAcceptance, Never>()
  let sendingMessageSubject = PassthroughSubject<WCMessage, Never>()
  let replyMessageSubject = PassthroughSubject<WCMessageResult, Never>()

  #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
      activationStateSubject.send(session)
    }

    func sessionDidDeactivate(_ session: WCSession) {
      activationStateSubject.send(session)
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
      DispatchQueue.main.async {
        self.isPairedSubject.send(session)
        self.isCompanionInstalledSubject.send(session)
      }
    }

  #elseif os(watchOS)

    func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
      isCompanionInstalledSubject.send(session)
    }
  #endif

  func session(_ session: WCSession, activationDidCompleteWith _: WCSessionActivationState, error _: Error?) {
    _session = session
    DispatchQueue.main.async {
      self.activationStateSubject.send(session)

      self.isReachableSubject.send(session)
      #if os(iOS)
        self.isCompanionInstalledSubject.send(session)
        self.isPairedSubject.send(session)
      #elseif os(watchOS)
        self.isCompanionInstalledSubject.send(session)
      #endif
    }
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    DispatchQueue.main.async {
      self.isReachableSubject.send(session)
    }
  }

  private func sendMessage(_ message: WCMessage) {
    if actualSession.isReachable {
      actualSession.sendMessage(message) { reply in
        self.replyMessageSubject.send((message, .reply(reply)))
      } errorHandler: { error in
        self.replyMessageSubject.send((message, .failure(error)))
      }
    } else if actualSession.isPairedAppInstalled {
      do {
        try actualSession.updateApplicationContext(message)
      } catch {
        replyMessageSubject.send((message, .failure(error)))

        return
      }
      replyMessageSubject.send((message, .applicationContext))
    } else {
      replyMessageSubject.send((message, .noCompanion))
    }
  }

  func session(_: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    messageReceivedSubject.send((message, .replyWith(replyHandler)))
  }

  func session(_: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    messageReceivedSubject.send((applicationContext, .applicationContext))
  }
}
