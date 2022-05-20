import Foundation
public protocol PathMonitor {
  associatedtype PathType: NetworkPath
  func onPathUpdate(_ handler: @escaping (PathType) -> Void)
  func start(queue: DispatchQueue)
  func cancel()
}
