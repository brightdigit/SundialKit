import Foundation

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
