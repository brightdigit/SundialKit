import Foundation
public protocol NetworkPing {
  associatedtype StatusType
  var timeInterval: TimeInterval { get }
  func shouldPing(onStatus status: NWPathStatus) -> Bool
  func onPing(_ closure: @escaping (StatusType) -> Void)
}

public extension NetworkPing {
  func onPingForFuture(_ closure: @escaping (Result<StatusType, Never>) -> Void) {
    onPing {
      closure(.success($0))
    }
  }
}
