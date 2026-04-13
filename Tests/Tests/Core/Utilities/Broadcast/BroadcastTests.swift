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
    var invokedOnMainThread = false
    sut.add(observer: listener)
    sut.invoke(on: .main) {
      $0.run()
      expectation.fulfill()
      invokedOnMainThread = Thread.current.isMainThread
    }
    waitForExpectations(timeout: 1, handler: nil)
    XCTAssert(invokedOnMainThread, "Listener should be notified on the main thread")
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
}

private protocol MockedProtocol {
  func run()
}

private class MockedListener: MockedProtocol {
  var executingCount = 0
  
  func run() {
    executingCount += 1
  }
}
