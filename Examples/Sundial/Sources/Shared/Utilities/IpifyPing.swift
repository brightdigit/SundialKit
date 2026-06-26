//
//  IpifyPing.swift
//  Sundial
//
//  Created by Leo Dion on 10/17/22.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import SundialKitCore
import SundialKitNetwork

/// A NetworkPing implementation that verifies connectivity by fetching the
/// public IP address from ipify.org.
///
/// Example usage:
/// ```swift
/// let ping = IpifyPing(session: .shared, timeInterval: 10.0)
/// let observer = NetworkObserver(
///   monitor: NWPathMonitorAdapter(),
///   ping: ping
/// )
/// ```
public struct IpifyPing: NetworkPing, Sendable {
  /// The public IP address returned from ipify.org, or nil if the request failed.
  public typealias StatusType = String?

  /// The ipify.org API endpoint for retrieving the public IP address.
  public static let url: URL = {
    guard let url = URL(string: "https://api.ipify.org") else {
      fatalError("Invalid ipify URL")
    }
    return url
  }()

  /// The URLSession used for making network requests.
  public let session: URLSession

  /// The time interval between ping attempts.
  public let timeInterval: TimeInterval

  /// Creates a new IpifyPing instance.
  ///
  /// - Parameters:
  ///   - session: The URLSession to use for requests. Defaults to `.shared`.
  ///   - timeInterval: The interval between ping attempts. Defaults to 10 seconds.
  public init(session: URLSession = .shared, timeInterval: TimeInterval = 10.0) {
    self.session = session
    self.timeInterval = timeInterval
  }

  /// Determines whether a ping should be performed based on the current network status.
  ///
  /// - Parameter status: The current PathStatus.
  /// - Returns: `true` if a ping should be performed, `false` otherwise.
  public func shouldPing(onStatus status: PathStatus) -> Bool {
    switch status {
    case .unknown, .unsatisfied:
      return false
    case .requiresConnection, .satisfied:
      return true
    }
  }

  /// Performs a network ping by fetching the public IP address.
  ///
  /// - Parameter closure: Called with the resulting IP address string, or nil if the request failed.
  public func onPing(_ closure: @escaping (String?) -> Void) {
    let task = session.dataTask(with: IpifyPing.url) { data, _, _ in
      closure(data.flatMap { String(data: $0, encoding: .utf8) })
    }
    task.resume()
  }
}
