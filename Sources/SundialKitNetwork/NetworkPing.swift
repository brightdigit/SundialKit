//
//  NetworkPing.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

public import Foundation
public import SundialKitCore

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

extension NetworkPing {
  // swiftlint:disable:next explicit_acl
  func onPingForFuture(_ closure: @escaping (Result<StatusType, Never>) -> Void) {
    onPing {
      closure(.success($0))
    }
  }
}

#if canImport(Combine)
  @available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
  extension NetworkPing {
    // swiftlint:disable:next explicit_acl
    func publish<PathStatusPublisher: Publisher>(
      with pathStatusPublisher: PathStatusPublisher
    ) -> AnyPublisher<StatusType, Never>
    where
      PathStatusPublisher.Output == PathStatus,
      PathStatusPublisher.Failure == Never
    {
      let timerPublisher =
        Timer
        .publish(
          every: timeInterval,
          on: .current,
          in: .common
        )
        .autoconnect()
        .prepend(.init())

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
