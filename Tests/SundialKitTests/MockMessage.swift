//
//  File.swift
//
//
//  Created by Leo Dion on 5/20/22.
//
import Foundation
import SundialKit

public struct MockMessage: Messagable, Equatable {
  public init() {
    key = UUID().uuidString
    value = UUID()
  }

  public init?(from parameters: [String: Any]?) {
    guard let pair = parameters?.first else {
      return nil
    }

    guard let value = pair.value as? UUID else {
      return nil
    }

    key = pair.key
    self.value = value
  }

  public static let key: String = UUID().uuidString
  internal let key: String
  internal let value: UUID
  public func parameters() -> [String: Any] {
    [key: value]
  }
}
