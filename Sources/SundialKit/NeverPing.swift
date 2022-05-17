import Foundation

public struct NeverPing: NetworkPing {
  private init() {}
  public var timeInterval: TimeInterval {
    .nan
  }

  public func shouldPing(onStatus _: NWPathStatus) -> Bool {
    false
  }

  public func onPing(_: @escaping (Never) -> Void) {}

  public typealias StatusType = Never
}
