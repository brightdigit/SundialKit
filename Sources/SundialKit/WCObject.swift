// swiftlint:disable file_length
import Combine
import Foundation
import SwiftUI

struct NotSupportedError: Error {}
public protocol WCSessionableDelegate: AnyObject {
  func session(_ session: WCSessionable,
               activationDidCompleteWith activationState: WCSessionActivationState,
               error: Error?)

  func sessionDidBecomeInactive(_ session: WCSessionable)

  func sessionDidDeactivate(_ session: WCSessionable)

  func sessionWatchStateDidChange(_ session: WCSessionable)

  func sessionReachabilityDidChange(_ session: WCSessionable)

  func session(_ session: WCSessionable,
               didReceiveMessage message: WCMessage,
               replyHandler: @escaping WCMessageHandler)

  func session(_ session: WCSessionable,
               didReceiveApplicationContext applicationContext: WCMessage,
               error: Error?)
}

public protocol WCSessionable: AnyObject {
  var delegate: WCSessionableDelegate? { get set }
  func activate() throws
  var isReachable: Bool { get }

  #if os(iOS)
    var isPaired: Bool { get }
  #endif
  var isCompanionAppInstalled: Bool { get }
  var activationState: WCSessionActivationState { get }

  func updateApplicationContext(_ context: WCMessage) throws
  func sendMessage(_ message: WCMessage,
                   _ completion: @escaping (Result<WCMessage, Error>) -> Void)
}

#if canImport(WatchConnectivity)
  import WatchConnectivity
#endif

public class WCObject: NSObject, WCSessionableDelegate, ObservableObject {
  public init(session: WCSessionable) {
    self.session = session
    super.init()
    cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
  }

  var cancellable: AnyCancellable!

  public func activate() throws {
    session.delegate = self
    try session.activate()
  }

  override public convenience init() {
    self.init(session: WatchConnectivitySession())
  }

  let session: WCSessionable

  let activationStateSubject = PassthroughSubject<WCSessionable, Never>()
  let isReachableSubject = PassthroughSubject<WCSessionable, Never>()

  let isPairedAppInstalledSubject = PassthroughSubject<WCSessionable, Never>()

  let isPairedSubject = PassthroughSubject<WCSessionable, Never>()

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
      for: \.isCompanionAppInstalled
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

  public func sessionWatchStateDidChange(_ session: WCSessionable) {
    DispatchQueue.main.async {
      self.isPairedSubject.send(session)
      self.isPairedAppInstalledSubject.send(session)
    }
  }

  public func sessionCompanionAppInstalledDidChange(_ session: WCSessionable) {
    DispatchQueue.main.async {
      self.isPairedAppInstalledSubject.send(session)
    }
  }

  public func session(_ session: WCSessionable,
                      activationDidCompleteWith _: WCSessionActivationState,
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
    } else if session.isCompanionAppInstalled {
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

  public func session(_: WCSessionable,
                      didReceiveMessage applicationContext: [String: Any]) {
    messageReceivedSubject.send((applicationContext, .applicationContext))
  }
}

#if canImport(WatchConnectivity)

  class WatchConnectivitySession: NSObject, WCSessionable, WCSessionDelegate {
    var isReachable: Bool {
      session.isReachable
    }

    @available(watchOS, unavailable)
    var isPaired: Bool {
      session.isPaired
    }

    var isCompanionAppInstalled: Bool {
      session.isPairedAppInstalled
    }

    var activationState: WCSessionActivationState {
      session.activationState
    }

    func updateApplicationContext(_ context: WCMessage) throws {
      try session.updateApplicationContext(context)
    }

    func sendMessage(_ message: WCMessage,
                     _ completion: @escaping (Result<WCMessage, Error>) -> Void) {
      session.sendMessage(message) { message in
        completion(.success(message))
      } errorHandler: { error in
        completion(.failure(error))
      }
    }

    internal init(session: WCSession) {
      self.session = session
      super.init()
      session.delegate = self
    }

    override convenience init() {
      self.init(session: .default)
    }

    let session: WCSession

    var delegate: WCSessionableDelegate?

    func activate() throws {
      guard WCSession.isSupported() else {
        throw NotSupportedError()
      }
      session.activate()
    }

    func session(_: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
      delegate?.session(self, activationDidCompleteWith: activationState, error: error)
    }

    #if os(iOS)

      func sessionDidBecomeInactive(_: WCSession) {
        delegate?.sessionDidBecomeInactive(self)
      }

      func sessionDidDeactivate(_: WCSession) {
        delegate?.sessionDidDeactivate(self)
      }

      func sessionWatchStateDidChange(_: WCSession) {
        delegate?.sessionWatchStateDidChange(self)
      }
    #endif

    func sessionReachabilityDidChange(_: WCSession) {
      delegate?.sessionReachabilityDidChange(self)
    }

    func session(_: WCSession,
                 didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
      delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
    }

    func session(_: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any]) {
      delegate?.session(self,
                        didReceiveApplicationContext: applicationContext, error: nil)
    }

    func session(_: WCSession,
                 didReceiveApplicationContext applicationContext: [String: Any],
                 error: Error?) {
      delegate?.session(self,
                        didReceiveApplicationContext: applicationContext,
                        error: error)
    }
  }

#endif
