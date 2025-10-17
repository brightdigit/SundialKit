//
//  NWInterfaceTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKit
@testable import SundialKitCore
@testable import SundialKitNetwork

#if canImport(Network)
  import Network
#endif

@Suite("NWInterface Tests")
internal struct NWInterfaceTests {
  #if canImport(Network)
    internal func rawValue(
      of interface: PathStatus.Interface,
      interfaceType: NWInterface.InterfaceType
    ) {
      #expect(interface.rawValue == interfaceType.value)
    }
  #endif

  @Test("Interface raw values match NWInterface types")
  internal func interfaceValues() throws {
    #if canImport(Network)

      rawValue(of: .wifi, interfaceType: .wifi)
      rawValue(of: .wiredEthernet, interfaceType: .wiredEthernet)
      rawValue(of: .loopback, interfaceType: .loopback)
      rawValue(of: .cellular, interfaceType: .cellular)
      rawValue(of: .other, interfaceType: .other)
    #endif
  }
}
