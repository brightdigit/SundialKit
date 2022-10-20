import Foundation

/// `NetworkPing` which is never called.
/// This used for a `NetworkObserver` that doesn't need a continuous ping.
public struct NeverPing: NetworkPing {
  public typealias StatusType = Never

  public var timeInterval: TimeInterval {
    .nan
  }

  private init() {}

  public func shouldPing(onStatus _: PathStatus) -> Bool {
    false
  }

  public func onPing(_: @escaping (Never) -> Void) {}
}
