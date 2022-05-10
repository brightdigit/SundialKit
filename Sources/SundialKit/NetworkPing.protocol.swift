import Foundation
public protocol NetworkPing {
  associatedtype StatusType
  var timeInterval: TimeInterval { get }
  func onPing(_ closure: @escaping (Result<StatusType, Never>) -> Void)
}
