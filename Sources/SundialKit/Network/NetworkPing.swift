import Foundation

#if canImport(Combine)
  import Combine
#endif

/// Called periodically to verify network connectivity
public protocol NetworkPing {
  /// The resulting status of the ping.
  associatedtype StatusType
  /// The amount of time between each verification
  var timeInterval: TimeInterval { get }
  /// Based on the `PathStatus` should it verify network connectivity.
  func shouldPing(onStatus status: PathStatus) -> Bool
  /// Invokes the network verification.
  func onPing(_ closure: @escaping (StatusType) -> Void)
}

internal extension NetworkPing {
  // swiftlint:disable:next explicit_acl
  func onPingForFuture(_ closure: @escaping (Result<StatusType, Never>) -> Void) {
    onPing {
      closure(.success($0))
    }
  }
}

#if canImport(Combine)
  @available(macOS 10.15, *)
  internal extension NetworkPing {
    // swiftlint:disable:next explicit_acl
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
