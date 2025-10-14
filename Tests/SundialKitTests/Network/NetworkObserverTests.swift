import Foundation
import XCTest

@testable import SundialKit
@testable import SundialKitNetwork

#if canImport(Combine)
  import Combine
#endif

internal final class NetworkObserverTests: XCTestCase, @unchecked Sendable {
  // swiftlint:disable:next function_body_length
  internal func testStart() throws {
    #if canImport(Combine)
      class StatusSet {
        var statuses = [MockNetworkPing.StatusType?]()

        func append(_ status: MockNetworkPing.StatusType?) -> Int {
          statuses.append(status)
          return statuses.count
        }

        func get(_ index: Int) -> MockNetworkPing.StatusType? {
          if index < statuses.count {
            return statuses[index]
          }
          return nil
        }
      }
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      var statuses = StatusSet()
      let pingStatusExpectaion = expectation(description: "ping status received")

      let cancellable = observer.pingStatusPublisher.sink { status in
        let count = statuses.append(status)
        if count > 1 {
          pingStatusExpectaion.fulfill()
        }
      }

      let dispatchQueueLabel = UUID().uuidString
      observer.start(queue: .init(label: dispatchQueueLabel))

      XCTAssertEqual(monitor.dispatchQueueLabel, dispatchQueueLabel)

      waitForExpectations(timeout: 10.0) { [statuses] error in
        XCTAssertNil(error)
        XCTAssertNotNil(statuses.get(0))
        XCTAssertNotNil(statuses.get(1))
        cancellable.cancel()
      }
    #else

    #endif
  }

  internal func testCancel() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      observer.start(queue: .init(label: UUID().uuidString))
      XCTAssertTrue(observer.isPingActive)

      observer.cancel()
      XCTAssertFalse(observer.isPingActive)
      XCTAssertTrue(monitor.isCancelled)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testPathStatusPublisher() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )

      var pathStatus: PathStatus?
      let cancellable = observer.pathStatusPublisher.sink {
        pathStatus = $0
      }
      monitor.sendPath(.init(pathStatus: .requiresConnection))
      XCTAssertEqual(pathStatus, .requiresConnection)
      cancellable.cancel()
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testIsExpensivePublisher() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      let expectedIsExpensive: Bool = .random()
      // swiftlint:disable:next discouraged_optional_boolean
      var actualIsExpensive: Bool?
      let cancellable = observer.isExpensivePublisher.sink {
        actualIsExpensive = $0
      }
      monitor.sendPath(.init(isExpensive: expectedIsExpensive))
      XCTAssertEqual(expectedIsExpensive, actualIsExpensive)
      cancellable.cancel()
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testIsConstrainedPublisher() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      let expectedIsConstrained: Bool = .random()
      // swiftlint:disable:next discouraged_optional_boolean
      var actualIsConstrained: Bool?
      let cancellable = observer.isConstrainedPublisher.sink {
        actualIsConstrained = $0
      }
      monitor.sendPath(.init(isConstrained: expectedIsConstrained))
      XCTAssertEqual(expectedIsConstrained, actualIsConstrained)
      cancellable.cancel()
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testInit() throws {
    #if canImport(Combine)
      let monitorID = UUID()
      let pingID = UUID()
      let observer = NetworkObserver(
        monitor: MockPathMonitor(id: monitorID),
        ping: MockNetworkPing(id: pingID, timeInterval: 2.0)
      )
      XCTAssertTrue(observer.hasNetworkPing)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testInitNever() throws {
    #if canImport(Combine)
      let monitorID = UUID()
      let observer = NetworkObserver(
        monitor: MockPathMonitor(id: monitorID)
      )
      XCTAssertFalse(observer.hasNetworkPing)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testInitNetwork() throws {
    #if canImport(Combine) && canImport(Network)
      let pingID = UUID()
      let observer = NetworkObserver(
        ping: MockNetworkPing(id: pingID, timeInterval: 2.0)
      )
      XCTAssertTrue(observer.hasNetworkPing)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  internal func testInitNetworkNever() throws {
    #if canImport(Combine) && canImport(Network)
      let observer = NetworkObserver()
      XCTAssertFalse(observer.hasNetworkPing)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }
}
