import Foundation

#if canImport(Combine)
  import Combine
#endif

/// Called periodically to verify network connectivity.
///
/// Here's an example which calls the _ipify_ API to verify there's a ip address:
/// ```swift
/// struct IpifyPing : NetworkPing {
///   typealias StatusType = String?
///
///   let session: URLSession
///   let timeInterval: TimeInterval
///
///   public func shouldPing(onStatus status: PathStatus) -> Bool {
///     switch status {
///     case .unknown, .unsatisfied:
///       return false
///     case .requiresConnection, .satisfied:
///       return true
///     }
///   }
///
///   static let url : URL = .init(string: "https://api.ipify.org")!
///
///   func onPing(_ closure: @escaping (String?) -> Void) {
///     session.dataTask(with: IpifyPing.url) { data, _, _ in
///       closure(data.flatMap{String(data: $0, encoding: .utf8)})
///     }.resume()
///   }
/// }
/// ```
///
/// In our `ObservableObject`, we can create a ``NetworkObserver`` to use this with:
///
/// ```swift
///   @Published var nwObject = NetworkObserver(ping:
///     // use the shared `URLSession` and check every 10.0 seconds
///     IpifyPing(session: .shared, timeInterval: 10.0)
///    )
/// ```
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
  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
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
