#if canImport(Combine)
  import Combine
  import Foundation

  /// Class for communication between the Apple Watch and iPhone.
  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  public class ConnectivityObserver: NSObject, ConnectivitySessionDelegate {
    /// `typealias` for `PassthroughSubject` without a `Failure`.
    private typealias SuccessfulSubject<Output> = PassthroughSubject<Output, Never>

    private let session: ConnectivitySession

    /// `Subject` for sending message through
    public let sendingMessageSubject = PassthroughSubject<ConnectivityMessage, Never>()

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var cancellable: AnyCancellable!

    private let activationStateSubject = SuccessfulSubject<ConnectivitySession>()
    private let isReachableSubject = SuccessfulSubject<ConnectivitySession>()
    private let isPairedAppInstalledSubject = SuccessfulSubject<ConnectivitySession>()
    private let isPairedSubject = SuccessfulSubject<ConnectivitySession>()
    private let messageReceivedSubject = SuccessfulSubject<ConnectivityReceiveResult>()
    private let replyMessageSubject = SuccessfulSubject<ConnectivitySendResult>()

    /// Creates a publisher for changes to the
    /// [`activationState`](../watchconnectivity/wcsession/1615663-activationstate)
    public var activationStatePublisher: AnyPublisher<ActivationState, Never> {
      activationStateSubject.anyPublisher(for: \.activationState)
    }

    /// Creates a publisher for changes to the
    /// [`isReachable`](../watchconnectivity/wcsession/1615683-isreachable) .
    public var isReachablePublisher: AnyPublisher<Bool, Never> {
      isReachableSubject.anyPublisher(for: \.isReachable)
    }

    /// Creates a publisher for changes to the
    /// [`isCompanionAppInstalled`](../watchconnectivity/wcsession/3235766-iscompanionappinstalled)
    /// or [`isWatchAppInstalled`](../watchconnectivity/wcsession/1615623-iswatchappinstalled).
    public var isPairedAppInstalledPublisher: AnyPublisher<Bool, Never> {
      isPairedAppInstalledSubject.anyPublisher(
        for: \.isPairedAppInstalled
      )
    }

    /// Creates a publisher for messages received through WatchConnectivity.
    public var messageReceivedPublisher: AnyPublisher<ConnectivityReceiveResult, Never> {
      messageReceivedSubject.eraseToAnyPublisher()
    }

    /// Creates a publisher for replies
    /// from send messages received through WatchConnectivity.
    public var replyMessagePublisher: AnyPublisher<ConnectivitySendResult, Never> {
      replyMessageSubject.eraseToAnyPublisher()
    }

    @available(watchOS, unavailable)
    /// Creates a publisher for changes
    /// to the [`isPaired`](../watchconnectivity/wcsession/1615665-ispaired) .
    public var isPairedPublisher: AnyPublisher<Bool, Never> {
      #if os(iOS)
        return isPairedSubject.anyPublisher(for: \.isPaired)
      #else
        return Empty(outputType: Bool.self, failureType: Never.self).eraseToAnyPublisher()
      #endif
    }

    internal init(session: ConnectivitySession) {
      self.session = session
      super.init()
      session.delegate = self
      cancellable = sendingMessageSubject.sink(receiveValue: sendMessage(_:))
    }

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    /// Creates a `ConnectivityObserver` which uses [WatchConnectivity](../watchconnectivity).
    override public convenience init() {
      #if canImport(WatchConnectivity)
        self.init(session: WatchConnectivitySession())
      #else
        self.init(session: NeverConnectivitySession())
      #endif
    }

    /// Sessions are always available on Apple Watch.
    /// They are also available on iPhones that support pairing with an Apple Watch.
    /// For all other devices, this will throw ``SundialError/sessionNotSupported``.
    ///
    /// - Throws: `SundialError.sessionNotSupported` if session is not supported.
    public func activate() throws {
      session.delegate = self
      try session.activate()
    }

    internal func sessionDidBecomeInactive(_ session: ConnectivitySession) {
      activationStateSubject.send(session)
    }

    internal func sessionDidDeactivate(_ session: ConnectivitySession) {
      activationStateSubject.send(session)
    }

    internal func sessionCompanionStateDidChange(_ session: ConnectivitySession) {
      DispatchQueue.main.async {
        self.isPairedSubject.send(session)
        self.isPairedAppInstalledSubject.send(session)
      }
    }

    internal func session(
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

    internal func sessionReachabilityDidChange(_ session: ConnectivitySession) {
      DispatchQueue.main.async {
        self.isReachableSubject.send(session)
      }
    }

    private func sendMessage(_ message: ConnectivityMessage) {
      if session.isReachable {
        session.sendMessage(message) { result in
          self.replyMessageSubject.send(.init(message: message, context: .init(result)))
        }
      } else if session.isPairedAppInstalled {
        do {
          try session.updateApplicationContext(message)
        } catch {
          replyMessageSubject.send(.init(message: message, context: .failure(error)))

          return
        }
        replyMessageSubject.send(.init(message: message, context: .applicationContext))
      } else {
        replyMessageSubject.send(
          .init(message: message, context: .failure(SundialError.missingCompanion))
        )
      }
    }

    internal func session(
      _: ConnectivitySession,
      didReceiveMessage message: [String: Any],
      replyHandler: @escaping ([String: Any]) -> Void
    ) {
      messageReceivedSubject.send(.init(message: message, context: .replyWith(replyHandler)))
    }

    internal func session(
      _: ConnectivitySession,
      didReceiveApplicationContext applicationContext: ConnectivityMessage,
      error _: Error?
    ) {
      messageReceivedSubject.send(.init(message: applicationContext, context: .applicationContext))
    }
  }
#endif
