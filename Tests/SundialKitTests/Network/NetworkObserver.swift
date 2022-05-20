import Foundation
@testable import SundialKit

import XCTest

public class NetworkObserverTests: XCTestCase {
  func testStart() {
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
  }

  func testCancel() {
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
  }

  public func testPathStatusPublisher() {
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
  }

  public func testIsExpensivePublisher() {
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
  }

  public func testIsConstrainedPublisher() {
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
  }

  public func testPingStatusPublisher() {}

  public func testOnUpdate() {}

  func testInit() {
    let monitorID = UUID()
    let pingID = UUID()
    let observer = NetworkObserver(
      monitor: MockPathMonitor(id: monitorID),
      ping: MockNetworkPing(id: pingID, timeInterval: 2.0)
    )

    XCTAssertEqual(monitorID, observer.monitor.id)
    XCTAssertEqual(pingID, observer.ping?.id)
  }

  func testInitNever() {
    let monitorID = UUID()
    let observer = NetworkObserver(
      monitor: MockPathMonitor(id: monitorID)
    )
    XCTAssertEqual(monitorID, observer.monitor.id)
    XCTAssertNil(observer.ping)
  }
}

// #if canImport(Combine)
//  import Combine
//  import Foundation
//  @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
//  public class NetworkObserver<MonitorType: PathMonitor, PingType: NetworkPing> {
//    let ping: PingType?
//    let monitor: MonitorType
//
//    let pathSubject = PassthroughSubject<MonitorType.PathType, Never>()
//    var pingCancellable: AnyCancellable?
//    var timerCancellable: Cancellable?
//    var otherCancellables = [AnyCancellable]()
//
//    let pathStatusSubject = PassthroughSubject<PathStatus, Never>()
//    let isExpensiveSubject = PassthroughSubject<Bool, Never>()
//    let isConstrainedSubject = PassthroughSubject<Bool, Never>()
//    let pingStatusSubject = PassthroughSubject<PingType.StatusType?, Never>()
//
//    internal init(monitor: MonitorType, pingOrNil: PingType?) {
//      self.monitor = monitor
//      ping = pingOrNil
//
//      // swiftlint:disable line_length
//      pathSubject.map(\.pathStatus).subscribe(pathStatusSubject).store(in: &otherCancellables)
//      pathSubject.map(\.isExpensive).subscribe(isExpensiveSubject).store(in: &otherCancellables)
//      pathSubject.map(\.isConstrained).subscribe(isConstrainedSubject).store(in: &otherCancellables)
//      // swiftlint:enable line_length
//
//      monitor.onPathUpdate(onUpdate(path:))
//    }
//
//    public func start(queue: DispatchQueue) {

//    }
//
//    public func cancel() {
//      if let timerCancellable = timerCancellable {
//        timerCancellable.cancel()
//        self.timerCancellable = nil
//      }
//
//      monitor.cancel()
//    }
//
//    public var pathStatusPublisher: AnyPublisher<PathStatus, Never> {
//      pathStatusSubject.eraseToAnyPublisher()
//    }
//
//    public var isExpensivePublisher: AnyPublisher<Bool, Never> {
//      isExpensiveSubject.eraseToAnyPublisher()
//    }
//
//    public var isConstrainedPublisher: AnyPublisher<Bool, Never> {
//      isConstrainedSubject.eraseToAnyPublisher()
//    }
//
//    public var pingStatusPublisher: AnyPublisher<PingType.StatusType?, Never> {
//      pingStatusSubject.eraseToAnyPublisher()
//    }
//
//    public func onUpdate(path: MonitorType.PathType) {
//      pathSubject.send(path)
//    }
//  }
//
//  @available(iOS 14.2, watchOS 7.1, macOS 11.0, *)
//  public extension NetworkObserver {
//    convenience init(monitor: MonitorType) where PingType == NeverPing {
//      self.init(monitor: monitor, pingOrNil: nil)
//    }
//
//    convenience init(monitor: MonitorType, ping: PingType) {
//      self.init(monitor: monitor, pingOrNil: ping)
//    }
//  }
// #endif
