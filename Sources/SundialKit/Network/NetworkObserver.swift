#if canImport(Combine)
  import Combine
  import Foundation

  @available(macOS 10.15, *)
  public class NetworkObserver<MonitorType: PathMonitor, PingType: NetworkPing> {
    let ping: PingType?
    let monitor: MonitorType

    let pathSubject = PassthroughSubject<MonitorType.PathType, Never>()
    var pingCancellable: AnyCancellable?
    var timerCancellable: Cancellable?
    var otherCancellables = [AnyCancellable]()

    let pathStatusSubject = PassthroughSubject<PathStatus, Never>()
    let isExpensiveSubject = PassthroughSubject<Bool, Never>()
    let isConstrainedSubject = PassthroughSubject<Bool, Never>()
    let pingStatusSubject = PassthroughSubject<PingType.StatusType?, Never>()

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

    func onUpdate(path: MonitorType.PathType) {
      pathSubject.send(path)
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
