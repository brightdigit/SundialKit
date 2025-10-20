//
//  File.swift
//
//
//  Created by Leo Dion on 5/20/22.
//
import Foundation

@testable import SundialKitConnectivity

internal struct MockMessage: Messagable, Equatable {
  internal static let key: String = UUID().uuidString
  internal let key: String
  internal let value: UUID
  internal init() {
    key = UUID().uuidString
    value = UUID()
  }

  internal init?(from parameters: [String: any Sendable]?) {
    guard let pair = parameters?.first else {
      return nil
    }

    guard let value = pair.value as? UUID else {
      return nil
    }

    key = pair.key
    self.value = value
  }

  internal func parameters() -> [String: any Sendable] {
    [key: value]
  }
}
