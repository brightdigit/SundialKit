import XCTest

@testable import SundialKitConnectivity

internal final class MessagableTests: XCTestCase {
  internal func testMessage() {
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
