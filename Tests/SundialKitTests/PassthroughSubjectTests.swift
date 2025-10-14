import XCTest

@testable import SundialKit

#if canImport(Combine)
  import Combine
#endif

internal class PassthroughSubjectTests: XCTestCase, @unchecked Sendable {
  private struct MockStruct {
    // swiftlint:disable:next strict_fileprivate
    fileprivate let id: UUID
  }

  
  internal func testAnyPublisher() throws {
    #if canImport(Combine)
      let expected = UUID()
      var actual: UUID?
      let expectation = expectation(description: "Publisher Works")
      let subject = PassthroughSubject<MockStruct, Never>()
      let cancellable = subject.anyPublisher(for: \.id).sink { value in
        actual = value
        expectation.fulfill()
      }
      subject.send(.init(id: expected))
      waitForExpectations(timeout: 1.0) { [actual] error in
        XCTAssertNil(error)
        XCTAssertEqual(expected, actual)
        cancellable.cancel()
      }
    #else
      throw XCTSkip("OS doesn't support Combine.")
    #endif
  }
}
