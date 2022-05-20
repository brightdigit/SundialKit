import Foundation

#if canImport(Combine)
  import Combine
#endif

public protocol NetworkPing {
  associatedtype StatusType
  var timeInterval: TimeInterval { get }
  func shouldPing(onStatus status: PathStatus) -> Bool
  func onPing(_ closure: @escaping (StatusType) -> Void)
}

public extension NetworkPing {
  func onPingForFuture(_ closure: @escaping (Result<StatusType, Never>) -> Void) {
    onPing {
      closure(.success($0))
    }
  }
}

#if canImport(Combine)
  @available(macOS 10.15, *)
  public extension NetworkPing {
    func publish<PathStatusPublisher: Publisher>(
      with pathStatusPublisher: PathStatusPublisher
    ) -> AnyPublisher<StatusType, Never>
      where
      PathStatusPublisher.Output == PathStatus,
      PathStatusPublisher.Failure == Never {
      let timerPublisher = Timer
        .publish(
          every: timeInterval,
          on: .current,
          in: .common
        )
        .autoconnect()

      return Publishers.CombineLatest(timerPublisher, pathStatusPublisher)
        .compactMap { _, status in
          self.shouldPing(onStatus: status) ? () : nil
        }
        .flatMap {
          Future(self.onPingForFuture(_:))
        }
        .eraseToAnyPublisher()
    }
  }
#endif
