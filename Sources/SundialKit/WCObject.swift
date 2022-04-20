import Combine
import Foundation

@available(macOS 10.15, *)
public class WCObject: NSObject, WCSessionableDelegate, ObservableObject {
  public init(session: WCSessionable) {
    self.session = session
    super.init()
    session.delegate = self
    cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
  }

  var cancellable: AnyCancellable!

  public func activate() throws {
    session.delegate = self
    try session.activate()
  }

  #if canImport(WatchConnectivity)

    override public convenience init() {
      self.init(session: WatchConnectivitySession())
    }

  #endif

  let session: WCSessionable

  let activationStateSubject = PassthroughSubject<WCSessionable, Never>()
  let isReachableSubject = PassthroughSubject<WCSessionable, Never>()

  let isPairedAppInstalledSubject = PassthroughSubject<WCSessionable, Never>()

  let isPairedSubject = PassthroughSubject<WCSessionable, Never>()

  let messageReceivedSubject = PassthroughSubject<WCMessageAcceptance, Never>()
  public let sendingMessageSubject = PassthroughSubject<WCMessage, Never>()
  let replyMessageSubject = PassthroughSubject<WCMessageResult, Never>()

  public var activationStatePublisher: AnyPublisher<ActivationState, Never> {
    activationStateSubject.anyPublisher(for: \.activationState)
  }

  public var isReachablePublisher: AnyPublisher<Bool, Never> {
    isReachableSubject.anyPublisher(for: \.isReachable)
  }

  public var isPairedAppInstalledPublisher: AnyPublisher<Bool, Never> {
    isPairedAppInstalledSubject.anyPublisher(
      for: \.isPairedAppInstalled
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
  #endif

  public func sessionDidBecomeInactive(_ session: WCSessionable) {
    activationStateSubject.send(session)
  }

  public func sessionDidDeactivate(_ session: WCSessionable) {
    activationStateSubject.send(session)
  }

  public func sessionCompanionStateDidChange(_ session: WCSessionable) {
    DispatchQueue.main.async {
      self.isPairedSubject.send(session)
      self.isPairedAppInstalledSubject.send(session)
    }
  }

  public func session(_ session: WCSessionable,
                      activationDidCompleteWith _: ActivationState,
                      error _: Error?) {
    DispatchQueue.main.async {
      self.activationStateSubject.send(session)

      self.isReachableSubject.send(session)
      self.isPairedAppInstalledSubject.send(session)
      #if os(iOS)
        self.isPairedSubject.send(session)
      #endif
    }
  }

  public func sessionReachabilityDidChange(_ session: WCSessionable) {
    DispatchQueue.main.async {
      self.isReachableSubject.send(session)
    }
  }

  fileprivate func sendMessage(_ message: WCMessage) {
    if session.isReachable {
      session.sendMessage(message) { result in
        self.replyMessageSubject.send((message, .init(result)))
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
      replyMessageSubject.send((message, .failure(SundialError.missingCompanion)))
    }
  }

  public func session(_: WCSessionable,
                      didReceiveMessage message: [String: Any],
                      replyHandler: @escaping ([String: Any]) -> Void) {
    messageReceivedSubject.send((message, .replyWith(replyHandler)))
  }

  public func session(_: WCSessionable,
                      didReceiveApplicationContext applicationContext: WCMessage,
                      error _: Error?) {
    messageReceivedSubject.send((applicationContext, .applicationContext))
  }
}
