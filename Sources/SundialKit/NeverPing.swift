import Foundation

public struct NeverPing: NetworkPing {
  private init() {}
  public var timeInterval: TimeInterval {
    .nan
  }

  public func onPing(_: @escaping (Never) -> Void) {}

  public typealias StatusType = Never
}
