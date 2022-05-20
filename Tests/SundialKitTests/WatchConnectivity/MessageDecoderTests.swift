import SundialKit
import XCTest

class MessageDecoderTests: XCTestCase {
  func testExample() throws {
    let decoder = MessageDecoder(messagableTypes: [MockMessage.self])
    let expMessage = MockMessage()
    let dict = expMessage.message()
    let actualMessage = decoder.decode(dict) as? MockMessage
    XCTAssertEqual(expMessage, actualMessage)
  }
}
