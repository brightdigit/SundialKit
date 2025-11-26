//
// ObserverRegistryTests.swift
// Copyright (c) 2025 BrightDigit.
//

import Testing

@testable import SundialKitCore

// MARK: - Observer Registry Tests

@Suite("ObserverRegistry Tests")
struct ObserverRegistryTests {
  @Test("Adding observer registers it in the registry")
  func testAddObserver() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    await registry.add(observer)

    let observers = await registry.snapshot()
    #expect(observers.count == 1)
    #expect(observers.first === observer)
  }

  @Test("Adding same observer twice registers it twice")
  func testAddDuplicateObserver() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    await registry.add(observer)
    await registry.add(observer)

    let observers = await registry.snapshot()
    // With strong references, duplicates are allowed - caller manages lifecycle
    #expect(observers.count == 2)
  }

  @Test("Adding multiple observers registers all of them")
  func testAddMultipleObservers() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    await registry.add(observer1)
    await registry.add(observer2)
    await registry.add(observer3)

    let observers = await registry.snapshot()
    #expect(observers.count == 3)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer2 })
    #expect(observers.contains { $0 === observer3 })
  }

  @Test("Removing observer unregisters it from the registry")
  func testRemoveObserver() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer = TestObserverImpl()

    await registry.add(observer)
    await registry.removeAll(where: { $0 === observer })

    let observers = await registry.snapshot()
    #expect(observers.isEmpty)
  }

  @Test("Removing observer that was not added has no effect")
  func testRemoveNonExistentObserver() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()

    await registry.add(observer1)
    await registry.removeAll(where: { $0 === observer2 })

    let observers = await registry.snapshot()
    #expect(observers.count == 1)
    #expect(observers.first === observer1)
  }

  @Test("Removing one observer leaves others intact")
  func testRemoveOneObserverKeepsOthers() async {
    let registry = ObserverRegistry<TestObserverImpl>()
    let observer1 = TestObserverImpl()
    let observer2 = TestObserverImpl()
    let observer3 = TestObserverImpl()

    await registry.add(observer1)
    await registry.add(observer2)
    await registry.add(observer3)

    await registry.removeAll(where: { $0 === observer2 })

    let observers = await registry.snapshot()
    #expect(observers.count == 2)
    #expect(observers.contains { $0 === observer1 })
    #expect(observers.contains { $0 === observer3 })
    #expect(!observers.contains { $0 === observer2 })
  }
}
