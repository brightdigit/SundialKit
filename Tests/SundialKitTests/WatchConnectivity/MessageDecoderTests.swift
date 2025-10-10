import XCTest

@testable import SundialKit

internal final class MessageDecoderTests: XCTestCase {
  internal func testExample() throws {
    let decoder = MessageDecoder(messagableTypes: [MockMessage.self])
    let expMessage = MockMessage()
    let dict = expMessage.message()
    let actualMessage = decoder.decode(dict) as? MockMessage
    XCTAssertEqual(expMessage, actualMessage)
  }
}
