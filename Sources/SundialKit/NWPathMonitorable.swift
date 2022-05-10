import Foundation
public protocol NWPathMonitorable {
  associatedtype PathType: NWPathable
  func onPathUpdate(_ handler: @escaping (PathType) -> Void)
  func start(queue: DispatchQueue)
  func cancel()
}
