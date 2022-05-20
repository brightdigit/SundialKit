#if canImport(Combine)
  import Combine
  import Foundation

  @available(macOS 10.15, *)
  public typealias SuccessfulSubject<Output> = Combine.PassthroughSubject<Output, Never>

  @available(macOS 10.15, *)
  public class ConnectivityObserver: NSObject, ConnectivitySessionDelegate {
    public let session: ConnectivitySession
    public let sendingMessageSubject = SuccessfulSubject<ConnectivityMessage>()

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var cancellable: AnyCancellable!

    private let activationStateSubject = SuccessfulSubject<ConnectivitySession>()
    private let isReachableSubject = SuccessfulSubject<ConnectivitySession>()
    private let isPairedAppInstalledSubject = SuccessfulSubject<ConnectivitySession>()
    private let isPairedSubject = SuccessfulSubject<ConnectivitySession>()
    private let messageReceivedSubject = SuccessfulSubject<ConnectivityReceiveResult>()
    private let replyMessageSubject = SuccessfulSubject<ConnectivitySendResult>()

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

    public var messageReceivedPublisher: AnyPublisher<ConnectivityReceiveResult, Never> {
      messageReceivedSubject.eraseToAnyPublisher()
    }

    public var replyMessagePublisher: AnyPublisher<ConnectivitySendResult, Never> {
      replyMessageSubject.eraseToAnyPublisher()
    }

    #if os(iOS)
      public var isPairedPublisher: AnyPublisher<Bool, Never> {
        isPairedSubject.anyPublisher(for: \.isPaired)
      }
    #endif

    public init(session: ConnectivitySession) {
      self.session = session
      super.init()
      session.delegate = self
      cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
    }

    #if canImport(WatchConnectivity)

      override public convenience init() {
        self.init(session: WatchConnectivitySession())
      }

    #endif

    public func activate() throws {
      session.delegate = self
      try session.activate()
    }

    public func sessionDidBecomeInactive(_ session: ConnectivitySession) {
      activationStateSubject.send(session)
    }

    public func sessionDidDeactivate(_ session: ConnectivitySession) {
      activationStateSubject.send(session)
    }

    public func sessionCompanionStateDidChange(_ session: ConnectivitySession) {
      DispatchQueue.main.async {
        self.isPairedSubject.send(session)
        self.isPairedAppInstalledSubject.send(session)
      }
    }

    public func session(
      _ session: ConnectivitySession,
      activationDidCompleteWith _: ActivationState,
      error _: Error?
    ) {
      DispatchQueue.main.async {
        self.activationStateSubject.send(session)

        self.isReachableSubject.send(session)
        self.isPairedAppInstalledSubject.send(session)
        #if os(iOS)
          self.isPairedSubject.send(session)
        #endif
      }
    }

    public func sessionReachabilityDidChange(_ session: ConnectivitySession) {
      DispatchQueue.main.async {
        self.isReachableSubject.send(session)
      }
    }

    private func sendMessage(_ message: ConnectivityMessage) {
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

    public func session(
      _: ConnectivitySession,
      didReceiveMessage message: [String: Any],
      replyHandler: @escaping ([String: Any]) -> Void
    ) {
      messageReceivedSubject.send((message, .replyWith(replyHandler)))
    }

    public func session(
      _: ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error _: Error?
    ) {
      messageReceivedSubject.send((applicationContext, .applicationContext))
    }
  }
#endif
