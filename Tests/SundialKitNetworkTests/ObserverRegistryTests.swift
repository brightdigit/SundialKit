//
//  ObserverRegistryTests.swift
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

@testable import SundialKitNetwork

// MARK: - Test Observer Protocol

private protocol TestObserver: AnyObject {
  var receivedValues: [Int] { get set }
}

// MARK: - Test Observer Implementation

private final class TestObserverImpl: TestObserver {
  var receivedValues: [Int] = []
}

// MARK: - Observer Registry Tests

@Suite("ObserverRegistry Tests")
struct ObserverRegistryTests {
  @Test("Adding observer registers it in the registry")
  func testAddObserver() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    registry.add(observer)

    let observers = registry.snapshot()
    #expect(observers.count == 1)
    #expect(observers.first === observer)
  }

  @Test("Adding same observer twice only registers it once")
  func testAddDuplicateObserver() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    registry.add(observer)
    registry.add(observer)

    let observers = registry.snapshot()
    #expect(observers.count == 1)
  }

  @Test("Adding multiple observers registers all of them")
  func testAddMultipleObservers() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    registry.add(observer1)
    registry.add(observer2)
    registry.add(observer3)

    let observers = registry.snapshot()
    #expect(observers.count == 3)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer2 })
    #expect(observers.contains { $0 === observer3 })
  }

  @Test("Removing observer unregisters it from the registry")
  func testRemoveObserver() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    registry.add(observer)
    registry.remove(observer)

    let observers = registry.snapshot()
    #expect(observers.isEmpty)
  }

  @Test("Removing observer that was not added has no effect")
  func testRemoveNonExistentObserver() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()

    registry.add(observer1)
    registry.remove(observer2)

    let observers = registry.snapshot()
    #expect(observers.count == 1)
    #expect(observers.first === observer1)
  }

  @Test("Removing one observer leaves others intact")
  func testRemoveOneObserverKeepsOthers() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    registry.add(observer1)
    registry.add(observer2)
    registry.add(observer3)

    registry.remove(observer2)

    let observers = registry.snapshot()
    #expect(observers.count == 2)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer3 })
    #expect(!observers.contains { $0 === observer2 })
  }

  @Test("Weak references are automatically cleaned up")
  func testWeakReferenceCleansUp() {
    let registry = ObserverRegistry<TestObserverImpl>()

    // Create observer in a scope
    do {
      let observer = TestObserverImpl()
      registry.add(observer)

      let observers = registry.snapshot()
      #expect(observers.count == 1)
    }

    // Observer should be deallocated now
    // Trigger cleanup by adding a new observer
    let newObserver = TestObserverImpl()
    registry.add(newObserver)

    let observers = registry.snapshot()
    #expect(observers.count == 1)
    #expect(observers.first === newObserver)
  }

  @Test("Notify executes action for all observers")
  func testNotify() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    registry.add(observer1)
    registry.add(observer2)
    registry.add(observer3)

    registry.notify { observer in
      observer.receivedValues.append(42)
    }

    #expect(observer1.receivedValues == [42])
    #expect(observer2.receivedValues == [42])
    #expect(observer3.receivedValues == [42])
  }

  @Test("Notify skips deallocated observers")
  func testNotifySkipsDeallocatedObservers() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()

    // Add an observer that will be deallocated
    do {
      let observer2 = TestObserverImpl()
      registry.add(observer2)
    }

    registry.add(observer1)

    var notificationCount = 0
    registry.notify { _ in
      notificationCount += 1
    }

    // Should only notify the one live observer
    #expect(notificationCount == 1)
  }

  @Test("Snapshot returns empty array when no observers")
  func testSnapshotEmpty() {
    let registry = ObserverRegistry<TestObserverImpl>()

    let observers = registry.snapshot()
    #expect(observers.isEmpty)
  }

  @Test("Snapshot returns current observers")
  func testSnapshot() {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()

    registry.add(observer1)
    registry.add(observer2)

    let observers = registry.snapshot()
    #expect(observers.count == 2)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer2 })
  }
}
