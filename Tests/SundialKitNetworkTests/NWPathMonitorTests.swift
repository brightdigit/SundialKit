//
// NWPathMonitorTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore
@testable import SundialKitNetwork

#if canImport(Network)
  import Network
#endif

@Suite("NWPathMonitor Tests")
internal struct NWPathMonitorTests {
  @Test("Path update handler can be set")

  internal func pathUpdate() throws {
    #if canImport(Network)
      let monitor = NWPathMonitor()
      #expect(monitor.pathUpdateHandler == nil)
      monitor.onPathUpdate { _ in
      }
      #expect(monitor.pathUpdateHandler != nil)
    #endif
  }
}
