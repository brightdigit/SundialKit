@testable import SundialKit
import XCTest

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
  let key: String
  let value: UUID
  public func parameters() -> [String: Any] {
    [key: value]
  }
}

class MessagableTests: XCTestCase {
  func testMessage() {
    let mockMessage = MockMessage()
    let dict = mockMessage.message()
    XCTAssertEqual(dict[MessagableKeys.typeKey] as? String, MockMessage.key)

    let actualParams = dict[MessagableKeys.parametersKey]
    guard let params = actualParams as? [String: Any] else {
      XCTAssertNotNil(actualParams)
      return
    }

    XCTAssertEqual(params[mockMessage.key] as? UUID, mockMessage.value)
  }
}
