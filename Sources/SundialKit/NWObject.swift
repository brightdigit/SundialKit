#if canImport(Combine)
  import Combine
  import Foundation
  @available(iOS 14.2, *)
  @available(watchOS 7.1, *)
  @available(macOS 11.0, *)
  public class NWObject<MonitorType: NWPathMonitorable, PingType: NetworkPing> {
    public init(monitor: MonitorType, ping: PingType?) {
      self.monitor = monitor
      self.ping = ping

      // swiftlint:disable line_length
      pathSubject.map(\.pathStatus).subscribe(pathStatusSubject).store(in: &otherCancellables)
      pathSubject.map(\.isExpensive).subscribe(isExpensiveSubject).store(in: &otherCancellables)
      pathSubject.map(\.isConstrained).subscribe(isConstrainedSubject).store(in: &otherCancellables)
      // swiftlint:enable line_length

      if let ping = ping {
        let timerPublisher = Timer.publish(
          every: ping.timeInterval,
          on: .current,
          in: .common
        )

        pingCancellable = Publishers.CombineLatest(timerPublisher, pathStatusSubject)
          .compactMap { _, status in
            status.isSatisfied ? () : nil
          }.flatMap {
            Future(ping.onPing)
          }.map { $0 as PingType.StatusType? }.subscribe(pingStatusSubject)
        self.timerPublisher = timerPublisher
      } else {
        timerPublisher = nil
      }
      monitor.onPathUpdate(onUpdate(path:))
    }

    public func start(queue: DispatchQueue) {
      if let timerPublisher = timerPublisher {
        let cancellable = timerPublisher.connect()
        timerCancellable = cancellable
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

    let timerPublisher: Timer.TimerPublisher?
    let ping: PingType?
    let monitor: MonitorType
    let pathSubject = PassthroughSubject<MonitorType.PathType, Never>()
    var pingCancellable: AnyCancellable?
    var timerCancellable: Cancellable?
    var otherCancellables = [AnyCancellable]()

    let pathStatusSubject = PassthroughSubject<NWPathStatus, Never>()
    let isExpensiveSubject = PassthroughSubject<Bool, Never>()
    let isConstrainedSubject = PassthroughSubject<Bool, Never>()
    let pingStatusSubject = PassthroughSubject<PingType.StatusType?, Never>()

    public var pathStatusPublisher: AnyPublisher<NWPathStatus, Never> {
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

    public func onUpdate(path: MonitorType.PathType) {
      pathSubject.send(path)
    }
  }
#endif
