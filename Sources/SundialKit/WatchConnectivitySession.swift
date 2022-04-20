#if canImport(WatchConnectivity)
  import WatchConnectivity
  class WatchConnectivitySession: NSObject, WCSessionable, WCSessionDelegate {
    var isReachable: Bool {
      session.isReachable
    }

    @available(watchOS, unavailable)
    var isPaired: Bool {
      session.isPaired
    }

    var isPairedAppInstalled: Bool {
      session.isPairedAppInstalled
    }

    var activationState: ActivationState {
      guard let state = ActivationState(rawValue: session.activationState.rawValue) else {
        preconditionFailure()
      }

      return state
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
        throw SundialError.sessionNotSupported
      }
      session.activate()
    }

    func session(_: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
      guard let activationState: ActivationState =
        .init(rawValue: activationState.rawValue) else {
        preconditionFailure()
      }
      delegate?.session(self,
                        activationDidCompleteWith: activationState,
                        error: error)
    }

    #if os(iOS)

      func sessionDidBecomeInactive(_: WCSession) {
        delegate?.sessionDidBecomeInactive(self)
      }

      func sessionDidDeactivate(_: WCSession) {
        delegate?.sessionDidDeactivate(self)
      }

      func sessionWatchStateDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
      }

    #elseif os(watchOS)

      public func sessionCompanionAppInstalledDidChange(_: WCSession) {
        delegate?.sessionCompanionStateDidChange(self)
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
