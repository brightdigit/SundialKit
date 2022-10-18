@testable import SundialKit
import XCTest

public final class MessageDecoderTests: XCTestCase {
  public func testExample() throws {
    let decoder = MessageDecoder(messagableTypes: [MockMessage.self])
    let expMessage = MockMessage()
    let dict = expMessage.message()
    let actualMessage = decoder.decode(dict) as? MockMessage
    XCTAssertEqual(expMessage, actualMessage)
  }
}
