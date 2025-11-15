//
//  MockPath.swift
//  SundialKitStream
//
//  Created by Leo Dion on 11/14/25.
//

@testable import SundialKitCore
@testable import SundialKitNetwork
@testable import SundialKitStream

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
