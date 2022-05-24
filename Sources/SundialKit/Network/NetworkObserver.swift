#if canImport(Combine)
  import Combine
  import Foundation

  /// Observes the status of network connectivity
  @available(macOS 10.15, *)
  public class NetworkObserver<MonitorType: PathMonitor, PingType: NetworkPing> {
    private let ping: PingType?
    private let monitor: MonitorType

    private let pathSubject = PassthroughSubject<MonitorType.PathType, Never>()
    private var pingCancellable: AnyCancellable?
    private var timerCancellable: Cancellable?
    private var otherCancellables = [AnyCancellable]()

    private let pathStatusSubject = PassthroughSubject<PathStatus, Never>()
    private let isExpensiveSubject = PassthroughSubject<Bool, Never>()
    private let isConstrainedSubject = PassthroughSubject<Bool, Never>()
    private let pingStatusSubject = PassthroughSubject<PingType.StatusType, Never>()

    internal var isPingActive: Bool {
      timerCancellable != nil
    }

    internal var hasNetworkPing: Bool {
      ping != nil
    }

    /// Publishes updates to the `PathStatus`
    public var pathStatusPublisher: AnyPublisher<PathStatus, Never> {
      pathStatusSubject.eraseToAnyPublisher()
    }

    /// Publishes updates to whether the network connection is expensive.
    public var isExpensivePublisher: AnyPublisher<Bool, Never> {
      isExpensiveSubject.eraseToAnyPublisher()
    }

    /// Publishes updates to whether the network connection is constrained.
    public var isConstrainedPublisher: AnyPublisher<Bool, Never> {
      isConstrainedSubject.eraseToAnyPublisher()
    }

    /// Publishes updates to the `PingType.StatusType`
    public var pingStatusPublisher: AnyPublisher<PingType.StatusType, Never> {
      pingStatusSubject.eraseToAnyPublisher()
    }

    internal init(monitor: MonitorType, pingOrNil: PingType?) {
      self.monitor = monitor
      ping = pingOrNil

      // swiftlint:disable line_length
      pathSubject.map(\.pathStatus).subscribe(pathStatusSubject).store(in: &otherCancellables)
      pathSubject.map(\.isExpensive).subscribe(isExpensiveSubject).store(in: &otherCancellables)
      pathSubject.map(\.isConstrained).subscribe(isConstrainedSubject).store(in: &otherCancellables)
      // swiftlint:enable line_length

      monitor.onPathUpdate(onUpdate(path:))
    }

    /// Starts the monitor.
    /// - Parameter queue: The `DispatchQueue` to start the `PathMonitor` on.
    public func start(queue: DispatchQueue) {
      timerCancellable = ping.map {
        $0.publish(with: self.pathStatusSubject)
          .subscribe(self.pingStatusSubject)
      }
      monitor.start(queue: queue)
    }

    /// Cancels the montor.
    public func cancel() {
      if let timerCancellable = timerCancellable {
        timerCancellable.cancel()
        self.timerCancellable = nil
      }

      monitor.cancel()
    }

    internal func onUpdate(path: MonitorType.PathType) {
      pathSubject.send(path)
    }
  }

  @available(macOS 10.15, *)
  public extension NetworkObserver {
    /// Creates `NetworkObserver` without a `NetworkPing` object.
    /// - Parameter monitor: The `PathMonitor` to monitor the network .
    convenience init(monitor: MonitorType) where PingType == NeverPing {
      self.init(monitor: monitor, pingOrNil: nil)
    }

    /// Creates `NetworkObserver` with a `NetworkPing` object.
    /// - Parameters:
    ///   - monitor: The `PathMonitor` to monitor the network .
    ///   - ping: The `NetworkPing` to ping periodically.
    convenience init(monitor: MonitorType, ping: PingType) {
      self.init(monitor: monitor, pingOrNil: ping)
    }
  }
#endif
