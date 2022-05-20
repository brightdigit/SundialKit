#if canImport(Combine)
  import Combine
  import Foundation
  // @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
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
      timerCancellable = ping.map { ping in
        let timerPublisher = Timer.publish(
          every: ping.timeInterval,
          on: .current,
          in: .common
        ).autoconnect()

        return Publishers.CombineLatest(timerPublisher, pathStatusSubject)
          .compactMap { _, status in
            ping.shouldPing(onStatus: status) ? () : nil
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

    public func onUpdate(path: MonitorType.PathType) {
      pathSubject.send(path)
    }
  }

  // @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
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
