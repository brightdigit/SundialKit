import Combine
@testable import SundialKit
import XCTest

class PassthroughSubjectTests: XCTestCase {
  struct MockStruct {
    let id: UUID
  }

  func testAnyPublisher() {
    let expected = UUID()
    var actual: UUID?
    let expectation = expectation(description: "Publisher Works")
    let subject = PassthroughSubject<MockStruct, Never>()
    let cancellable = subject.anyPublisher(for: \.id).sink { value in
      actual = value
      expectation.fulfill()
    }
    subject.send(.init(id: expected))
    waitForExpectations(timeout: 1.0) { error in
      XCTAssertNil(error)
      XCTAssertEqual(expected, actual)
      cancellable.cancel()
    }
  }
}
