#if canImport(Combine)
  import Combine
  import Foundation

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
    private let pingStatusSubject = PassthroughSubject<PingType.StatusType?, Never>()

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

    public func start(queue: DispatchQueue) {
      timerCancellable = ping.map {
        $0.publish(with: self.pathStatusSubject)
          .map { $0 as PingType.StatusType? }
          .subscribe(self.pingStatusSubject)
      }
      monitor.start(queue: queue)
      pingStatusSubject.send(nil)
    }

    public func cancel() {
      if let timerCancellable = timerCancellable {
        timerCancellable.cancel()
        self.timerCancellable = nil
      }

      monitor.cancel()
    }

    public var pathStatusPublisher: AnyPublisher<PathStatus, Never> {
      pathStatusSubject.eraseToAnyPublisher()
    }

    public var isExpensivePublisher: AnyPublisher<Bool, Never> {
      isExpensiveSubject.eraseToAnyPublisher()
    }

    public var isConstrainedPublisher: AnyPublisher<Bool, Never> {
      isConstrainedSubject.eraseToAnyPublisher()
    }

    public var pingStatusPublisher: AnyPublisher<PingType.StatusType?, Never> {
      pingStatusSubject.eraseToAnyPublisher()
    }

    internal func onUpdate(path: MonitorType.PathType) {
      pathSubject.send(path)
    }

    internal var isPingActive: Bool {
      timerCancellable != nil
    }

    internal var hasNetworkPing: Bool {
      ping != nil
    }
  }

  @available(macOS 10.15, *)
  public extension NetworkObserver {
    convenience init(monitor: MonitorType) where PingType == NeverPing {
      self.init(monitor: monitor, pingOrNil: nil)
    }

    convenience init(monitor: MonitorType, ping: PingType) {
      self.init(monitor: monitor, pingOrNil: ping)
    }
  }
#endif
