//
//  PassthroughSubjectTests.swift
//  SundialKit
//
//  Created by Leo Dion.
//  Copyright © 2025 BrightDigit.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
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
