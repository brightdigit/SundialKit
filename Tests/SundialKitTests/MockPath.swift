import Foundation
import SundialKit

@testable import SundialKitCore

internal struct MockPath: NetworkPath {
  internal let isConstrained: Bool

  internal let isExpensive: Bool

  internal let pathStatus: PathStatus
  internal init(
    isConstrained: Bool = false,
    isExpensive: Bool = false,
    pathStatus: PathStatus = .unknown
  ) {
    self.isConstrained = isConstrained
    self.isExpensive = isExpensive
    self.pathStatus = pathStatus
  }
}
