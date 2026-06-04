//
//  ObserverRegistryTests+NotifyTests.swift
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

import Testing

@testable import SundialKitCore

extension ObserverRegistryTests {
  @Test("Strong references keep observers alive")
  func testStrongReferencesKeepObserversAlive() async {
    let registry = ObserverRegistry<TestObserverImpl>()

    // Create observer in a scope
    do {
      let observer = TestObserverImpl()
      await registry.add(observer)

      let observers = await registry.snapshot()
      #expect(observers.count == 1)
    }

    // With strong references, observer is still kept alive by registry
    let newObserver = TestObserverImpl()
    await registry.add(newObserver)

    let observers = await registry.snapshot()
    // Both observers should still be in the registry (strong references)
    #expect(observers.count == 2)
  }

  @Test("Notify executes action for all observers")
  func testNotify() async throws {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    await registry.add(observer1)
    await registry.add(observer2)
    await registry.add(observer3)

    await registry.notify { observer in
      observer.receivedValues.append(42)
    }

    #expect(observer1.receivedValues == [42])
    #expect(observer2.receivedValues == [42])
    #expect(observer3.receivedValues == [42])
  }

  @Test("Notify with strong references keeps all observers")
  func testNotifyWithStrongReferences() async throws {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()

    await registry.add(observer1)
    await registry.add(observer2)

    await registry.notify { observer in
      observer.receivedValues.append(99)
    }

    // Both observers should receive the notification (strong references)
    #expect(observer1.receivedValues == [99])
    #expect(observer2.receivedValues == [99])
  }

  @Test("Snapshot returns empty array when no observers")
  func testSnapshotEmpty() async {
    let registry = ObserverRegistry<TestObserverImpl>()

    let observers = await registry.snapshot()
    #expect(observers.isEmpty)
  }

  @Test("Snapshot returns current observers")
  func testSnapshot() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()

    await registry.add(observer1)
    await registry.add(observer2)

    let observers = await registry.snapshot()
    #expect(observers.count == 2)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer2 })
  }
}
