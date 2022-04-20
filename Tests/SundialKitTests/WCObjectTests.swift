import Combine
import Foundation
import SwiftUI

import SundialKit
import WatchConnectivity
import XCTest

public class WCObjectTest: XCTestCase {
  public func testActivate() throws {
    let wcObject = WCObject()
    try wcObject.activate()
    wcObject.session
  }

  public func testActivationStatePublisher() {
    XCTFail()
  }

  public func testIsReachablePublisher() {
    XCTFail()
  }

  public func testIsPairedAppInstalledPublisher() {
    XCTFail()
  }

  public func testMessageReceivedPublisher() {
    XCTFail()
  }

  public func testReplyMessagePublisher() {
    XCTFail()
  }

  public func testIsPairedPublisher() {
    XCTFail()
  }
}
