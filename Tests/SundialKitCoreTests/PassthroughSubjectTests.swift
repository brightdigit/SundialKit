//
//  PassthroughSubjectTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//

import Foundation
import Testing

@testable import SundialKitCore

#if canImport(Combine)
  import Combine
#endif

@Suite("PassthroughSubject Tests")
internal struct PassthroughSubjectTests {
  private struct MockStruct {
    fileprivate let id: UUID
  }

  @Test("AnyPublisher maps keypath correctly")
  internal func anyPublisher() async throws {
    #if canImport(Combine)
      let expected = UUID()
      var actual: UUID?
      let subject = PassthroughSubject<MockStruct, Never>()

      await confirmation("Publisher works") { confirm in
        let cancellable = subject.anyPublisher(for: \.id).sink { value in
          actual = value
          confirm()
        }

        subject.send(.init(id: expected))

        // Keep cancellable alive
        withExtendedLifetime(cancellable) {}
      }

      #expect(expected == actual)
    #endif
  }
}
