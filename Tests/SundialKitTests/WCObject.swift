import Combine
import Foundation
import SwiftUI

#if canImport(WatchConnectivity)
  import WatchConnectivity

  public class WCObject: NSObject, WCSessionDelegate, ObservableObject {
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

    override public init() {
      super.init()
      cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
    }

    // swiftlint:disable:next identifier_name
    var _session: WCSession?

    var session: WCSession {
      _session ?? WCSession.default
    }

    let activationStateSubject = PassthroughSubject<WCSession, Never>()
    let isReachableSubject = PassthroughSubject<WCSession, Never>()

    let isPairedAppInstalledSubject = PassthroughSubject<WCSession, Never>()
    #if os(iOS)
      let isPairedSubject = PassthroughSubject<WCSession, Never>()
    #endif

    let messageReceivedSubject = PassthroughSubject<WCMessageAcceptance, Never>()
    public let sendingMessageSubject = PassthroughSubject<WCMessage, Never>()
    let replyMessageSubject = PassthroughSubject<WCMessageResult, Never>()

    public var activationStatePublisher: AnyPublisher<WCSessionActivationState, Never> {
      activationStateSubject.anyPublisher(for: \.activationState)
    }

    public var isReachablePublisher: AnyPublisher<Bool, Never> {
      isReachableSubject.anyPublisher(for: \.isReachable)
    }

    public var isPairedAppInstalledPublisher: AnyPublisher<Bool, Never> {
      isPairedAppInstalledSubject.anyPublisher(
        for: WCSession.isCompanionAppInstalledKeyPath
      )
    }

    public var messageReceivedPublisher: AnyPublisher<WCMessageAcceptance, Never> {
      messageReceivedSubject.eraseToAnyPublisher()
    }

    public var replyMessagePublisher: AnyPublisher<WCMessageResult, Never> {
      replyMessageSubject.eraseToAnyPublisher()
    }

    #if os(iOS)

      public var isPairedPublisher: AnyPublisher<Bool, Never> {
        isPairedSubject.anyPublisher(for: \.isPaired)
      }

      public func sessionDidBecomeInactive(_ session: WCSession) {
        activationStateSubject.send(session)
      }

      public func sessionDidDeactivate(_ session: WCSession) {
        activationStateSubject.send(session)
      }

      public func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
          self.isPairedSubject.send(session)
          self.isPairedAppInstalledSubject.send(session)
        }
      }

    #elseif os(watchOS)

      public func sessionCompanionAppInstalledDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
          self.isPairedAppInstalledSubject.send(session)
        }
      }
    #endif

    public func session(_ session: WCSession,
                        activationDidCompleteWith _: WCSessionActivationState,
                        error _: Error?) {
      _session = session
      DispatchQueue.main.async {
        self.activationStateSubject.send(session)

        self.isReachableSubject.send(session)
        self.isPairedAppInstalledSubject.send(session)
        #if os(iOS)
          self.isPairedSubject.send(session)
        #endif
      }
    }

    public func sessionReachabilityDidChange(_ session: WCSession) {
      DispatchQueue.main.async {
        self.isReachableSubject.send(session)
      }
    }

    fileprivate func sendMessage(_ message: WCMessage) {
      if session.isReachable {
        session.sendMessage(message) { reply in
          self.replyMessageSubject.send((message, .reply(reply)))
        } errorHandler: { error in
          self.replyMessageSubject.send((message, .failure(error)))
        }
      } else if session.isPairedAppInstalled {
        do {
          try session.updateApplicationContext(message)
        } catch {
          replyMessageSubject.send((message, .failure(error)))

          return
        }
        replyMessageSubject.send((message, .applicationContext))
      } else {
        replyMessageSubject.send((message, .noCompanion))
      }
    }

    public func session(_: WCSession,
                        didReceiveMessage message: [String: Any],
                        replyHandler: @escaping ([String: Any]) -> Void) {
      messageReceivedSubject.send((message, .replyWith(replyHandler)))
    }

    public func session(_: WCSession,
                        didReceiveApplicationContext applicationContext: [String: Any]) {
      messageReceivedSubject.send((applicationContext, .applicationContext))
    }
  }
#endif
