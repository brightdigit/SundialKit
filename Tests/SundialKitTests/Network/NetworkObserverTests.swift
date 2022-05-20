import Foundation
@testable import SundialKit

import XCTest

public class NetworkObserverTests: XCTestCase {
  func testStart() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      var statuses = [MockNetworkPing.StatusType?]()
      let pingStatusExpectaion = expectation(description: "ping status received")

      let cancellable = observer.pingStatusPublisher.sink { status in
        statuses.append(status)
        if statuses.count > 1 {
          pingStatusExpectaion.fulfill()
        }
      }

      let dispatchQueueLabel = UUID().uuidString
      observer.start(queue: .init(label: dispatchQueueLabel))

      XCTAssertEqual(monitor.dispatchQueueLabel, dispatchQueueLabel)

      waitForExpectations(timeout: 10.0) { error in
        XCTAssertNil(error)
        XCTAssertNil(statuses[0])
        XCTAssertNotNil(statuses[1])
        cancellable.cancel()
      }
    #else

    #endif
  }

  func testCancel() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      observer.start(queue: .init(label: UUID().uuidString))
      XCTAssertNotNil(observer.timerCancellable)
      observer.cancel()
      XCTAssertNil(observer.timerCancellable)
      XCTAssertTrue(monitor.isCancelled)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  public func testPathStatusPublisher() throws {
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

  public func testIsExpensivePublisher() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      let expectedIsExpensive: Bool = .random()
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

  public func testIsConstrainedPublisher() throws {
    #if canImport(Combine)
      let monitor = MockPathMonitor(id: UUID())
      let ping = MockNetworkPing(id: UUID(), timeInterval: 1.0)
      let observer = NetworkObserver(
        monitor: monitor,
        ping: ping
      )
      let expectedIsConstrained: Bool = .random()
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

  func testInit() throws {
    #if canImport(Combine)
      let monitorID = UUID()
      let pingID = UUID()
      let observer = NetworkObserver(
        monitor: MockPathMonitor(id: monitorID),
        ping: MockNetworkPing(id: pingID, timeInterval: 2.0)
      )

      XCTAssertEqual(monitorID, observer.monitor.id)
      XCTAssertEqual(pingID, observer.ping?.id)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }

  func testInitNever() throws {
    #if canImport(Combine)
      let monitorID = UUID()
      let observer = NetworkObserver(
        monitor: MockPathMonitor(id: monitorID)
      )
      XCTAssertEqual(monitorID, observer.monitor.id)
      XCTAssertNil(observer.ping)
    #else
      throw XCTSkip("Combine is not supported by this OS.")
    #endif
  }
}
