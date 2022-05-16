#if canImport(Combine)
  import Combine
  import Foundation
  @available(iOS 14.2, *)
  @available(watchOS 7.1, *)
  @available(macOS 11.0, *)
  public class NWObject<MonitorType: NWPathMonitorable, PingType: NetworkPing> {
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

    public init(monitor: MonitorType, ping: PingType?) {
      self.monitor = monitor
      self.ping = ping

      // swiftlint:disable line_length
      pathSubject.map(\.pathStatus).subscribe(pathStatusSubject).store(in: &otherCancellables)
      pathSubject.map(\.isExpensive).subscribe(isExpensiveSubject).store(in: &otherCancellables)
      pathSubject.map(\.isConstrained).subscribe(isConstrainedSubject).store(in: &otherCancellables)
      // swiftlint:enable line_length

      monitor.onPathUpdate(onUpdate(path:))
    }

    public func start(queue: DispatchQueue) {
      timerCancellable = ping.map { ping in
        let timerPublisher = Timer.publish(
          every: ping.timeInterval,
          on: .current,
          in: .common
        ).autoconnect()

        return Publishers.CombineLatest(timerPublisher, pathStatusSubject)
          .compactMap { _, status in
            status.isSatisfied ? () : nil
          }.flatMap {
            Future(ping.onPingForFuture(_:))
          }.map { $0 as PingType.StatusType? }.subscribe(pingStatusSubject)
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
