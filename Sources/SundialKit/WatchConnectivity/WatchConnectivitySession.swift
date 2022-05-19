#if canImport(WatchConnectivity)
  import WatchConnectivity

  typealias WatchConnectivitySessionProtocol = ConnectivitySession & WCSessionDelegate
  internal class WatchConnectivitySession: NSObject, WatchConnectivitySessionProtocol {
    private let session: WCSession

    internal var delegate: ConnectivitySessionDelegate?

    internal var isReachable: Bool {
      session.isReachable
    }

    @available(watchOS, unavailable)
    internal var isPaired: Bool {
      session.isPaired
    }

    internal var isPairedAppInstalled: Bool {
      session.isPairedAppInstalled
    }

    internal var activationState: ActivationState {
      guard let state = ActivationState(rawValue: session.activationState.rawValue) else {
        preconditionFailure()
      }

      return state
    }

    internal init(session: WCSession) {
      self.session = session
      super.init()
      session.delegate = self
    }

    override internal convenience init() {
      self.init(session: .default)
    }

    internal func updateApplicationContext(_ context: ConnectivityMessage) throws {
      try session.updateApplicationContext(context)
    }

    internal func sendMessage(
      _ message: ConnectivityMessage,
      _ completion: @escaping (Result<ConnectivityMessage, Error>) -> Void
    ) {
      session.sendMessage(
        message
      ) { message in
        completion(.success(message))
      }
      errorHandler: { error in
        completion(.failure(error))
      }
    }

    internal func activate() throws {
      guard WCSession.isSupported() else {
        throw SundialError.sessionNotSupported
      }
      session.activate()
    }

    internal func session(
      _: WCSession,
      activationDidCompleteWith activationState: WCSessionActivationState,
      error: Error?
    ) {
      guard let activationState: ActivationState =
        .init(rawValue: activationState.rawValue) else {
        preconditionFailure()
      }
      delegate?.session(
        self,
        activationDidCompleteWith: activationState,
        error: error
      )
    }

    #if os(iOS)

      internal func sessionDidBecomeInactive(_: WCSession) {
        delegate?.sessionDidBecomeInactive(self)
      }

      internal func sessionDidDeactivate(_: WCSession) {
        delegate?.sessionDidDeactivate(self)
      }

      internal func sessionWatchStateDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
      }

    #elseif os(watchOS)

      internal func sessionCompanionAppInstalledDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
      }
    #endif

    internal func sessionReachabilityDidChange(_: WCSession) {
      delegate?.sessionReachabilityDidChange(self)
    }

    internal func session(
      _: WCSession,
      didReceiveMessage message: [String: Any],
      replyHandler: @escaping ([String: Any]) -> Void
    ) {
      delegate?.session(self, didReceiveMessage: message, replyHandler: replyHandler)
    }

    internal func session(
      _: WCSession,
      didReceiveApplicationContext applicationContext: [String: Any]
    ) {
      delegate?.session(
        self,
        didReceiveApplicationContext: applicationContext,
        error: nil
      )
    }

    internal func session(
      _: WCSession,
      didReceiveApplicationContext applicationContext: [String: Any],
      error: Error?
    ) {
      delegate?.session(
        self,
        didReceiveApplicationContext: applicationContext,
        error: error
      )
    }
  }

#endif
