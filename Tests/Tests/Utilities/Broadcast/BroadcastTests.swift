//
//  BroadcastTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

// Main-actor isolation matches how `XCTestCase` already drives these
// test methods. `Broadcast.invoke(on:)` hops to `.main` in several
// cases, and running the tests on the main actor means the closures
// we hand to `invoke` can capture `self` without Swift 6 flagging the
// hand-off as a "sending non-Sendable value" data race.
@MainActor
class BroadcastTests: XCTestCase {

  func testWillNotifyListenerWhenBroadcastInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(observer: listener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 1, "Listener should be notified only once")
  }
  
  func testWillNotifyListenerWhenBroadcastInvokedOnMainQueue() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let expectation = self.expectation(description: "delay")
    
    sut.add(observer: listener)
    sut.invoke(on: .main) {
      $0.run()
      expectation.fulfill()
    }
    waitForExpectations(timeout: 1, handler: nil)
    XCTAssertEqual(listener.executingCount, 1, "Listener should be notified exactly once")
  }
  
  func testListenerNotifiedOnMainThreadWhenBroadcastInvokedOnMainThread() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let expectation = self.expectation(description: "delay")
    let invokedOnMainThread = BroadcastLockedBox<Bool>()
    invokedOnMainThread.set(false)
    sut.add(observer: listener)
    sut.invoke(on: .main) {
      $0.run()
      expectation.fulfill()
      invokedOnMainThread.set(Thread.current.isMainThread)
    }
    waitForExpectations(timeout: 1, handler: nil)
    XCTAssertEqual(invokedOnMainThread.value, true, "Listener should be notified on the main thread")
  }
  
  func testWillNotifyListenerTwiceWhenBroadcastInvokedTwice() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(observer: listener)
    sut.invoke { $0.run() }
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 2, "Listener should be notified exactly two times")
  }
  
  func testWontNotifyListenerWhenBroadcastClearedAndInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(observer: listener)
    sut.clear()
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 0, "Listener should not be notified when broadcast is cleared before invokation")
  }
  
  func testWillNotifyTwoListenersWhenBroadcastInvoked() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    let anotherlistener = MockedListener()
    sut.add(observer: listener)
    sut.add(observer: anotherlistener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 1, "First listener should be notified only once")
    XCTAssertEqual(anotherlistener.executingCount, 1, "Second listener should be notified only once")
  }
  
  func testWontNotifyListenerWhenUnsubscribed() {
    let sut = Broadcast<MockedProtocol>()
    let listener = MockedListener()
    sut.add(observer: listener)
    sut.remove(observer: listener)
    sut.invoke { $0.run() }
    XCTAssertEqual(listener.executingCount, 0, "Listener should not be notified when not subscrubed to broadcast")
  }
  
  func testRemoveObserver() {
    let sut = Broadcast<MockedProtocol>()
    let count = 100
    let removeCount = 40
    var listeners = (0..<count).map { _ in MockedListener() }
    for i in 0..<count {
      sut.add(observer: listeners[i])
    }
    for _ in 0..<removeCount {
      let randomRemoveIndex = Int.random(in: 0..<listeners.count)
      sut.remove(observer: listeners[randomRemoveIndex])
      listeners.remove(at: randomRemoveIndex) 
    }
    sut.invoke { $0.run() }
    XCTAssertEqual(count - removeCount, listeners.map { $0.executingCount }.reduce(0, +))
  }
  
  func testWeaklyHeldObserversAreAutomaticallyPruned() {
    let sut = Broadcast<MockedProtocol>()
    var listener: MockedListener? = MockedListener()
    sut.add(observer: listener!)
    XCTAssertEqual(sut.observerCount, 1, "Listener should be counted while alive")
    
    listener = nil
    
    // `observerCount` prunes stale references before returning.
    XCTAssertEqual(sut.observerCount, 0, "Stale weak references should be pruned")
  }
}

private protocol MockedProtocol: AnyObject {
  func run()
}

private class MockedListener: MockedProtocol {
  var executingCount = 0
  
  func run() {
    executingCount += 1
  }
}

/// Thread-safe box for observing scalar values from `@Sendable` closures.
private final class BroadcastLockedBox<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: Value?

  func set(_ value: Value) {
    lock.withLock { storage = value }
  }

  var value: Value? {
    lock.withLock { storage }
  }
}
