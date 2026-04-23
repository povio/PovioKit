//
//  DispatchTimerTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 19/09/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

// `@MainActor` matches how `XCTestCase` already invokes these test
// methods (on the main queue) and lets the `DispatchTimer` callbacks
// — which schedule onto `.main` — capture `self` without tripping
// Swift 6 strict concurrency's "sending non-Sendable value" diagnostic.
@MainActor
final class DispatchTimerTests: XCTestCase {
  func test_dispatchTimer_instance_noRepeating() {
    let timer = DispatchTimer()
    XCTAssertFalse(timer.isActive)
    
    let promise = expectation(description: "Wait for timer...")
    timer.schedule(interval: .milliseconds(100), repeating: false, on: .main) {
      promise.fulfill()
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_instance_repeating() {
    let timer = DispatchTimer()
    XCTAssertFalse(timer.isActive)
    
    let promise = expectation(description: "Wait for timer...")
    promise.expectedFulfillmentCount = 5
    let repeatCount = TimerCounter()
    
    timer.schedule(interval: .milliseconds(50), repeating: true, on: .main) { [weak timer] in
      promise.fulfill()
      let count = repeatCount.increment()
      if count >= 5 {
        timer?.stop()
      }
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_static_noRepeating() {
    let promise = expectation(description: "Wait for timer...")
    let timer = DispatchTimer.scheduled(interval: .milliseconds(100), repeating: false, on: .main) { _ in
      promise.fulfill()
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_static_repeating() {
    let promise = expectation(description: "Wait for timer...")
    promise.expectedFulfillmentCount = 5
    let repeatCount = TimerCounter()
    
    let timer = DispatchTimer.scheduled(interval: .milliseconds(50), repeating: true, on: .main) { timer in
      let count = repeatCount.increment()
      promise.fulfill()
      
      if count >= 5 {
        timer.stop()
      }
    }
    
    XCTAssertTrue(timer.isActive)
    waitForExpectations(timeout: 0.5)
    XCTAssertFalse(timer.isActive)
  }
  
  func test_dispatchTimer_stop() {
    let timer = DispatchTimer()
    
    (0...100).forEach { _ in
      XCTAssertFalse(timer.isActive)
      timer.schedule(interval: .milliseconds(1), repeating: false, on: .main, nil)
      
      XCTAssertTrue(timer.isActive)
      timer.stop()
      XCTAssertFalse(timer.isActive)
    }
  }
  
  func test_dispatchTimer_schedule_replacesPreviouslyScheduledTimer() {
    let timer = DispatchTimer()
    let promise = expectation(description: "Second timer executes")
    let firstFired = TimerFlag()
    let secondFired = TimerFlag()
    
    timer.schedule(interval: .milliseconds(120), repeating: false, on: .main) {
      firstFired.set()
    }
    timer.schedule(interval: .milliseconds(20), repeating: false, on: .main) {
      secondFired.set()
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 0.5)
    XCTAssertTrue(secondFired.isSet)
    XCTAssertFalse(firstFired.isSet)
  }
  
  func test_dispatchTimer_concurrentScheduleAndStop() {
    // Regression guard for unsynchronized mutation of the internal timer
    // source. Before 7.0 this loop could occasionally crash or leave the
    // timer in an inconsistent `isActive` state.
    let timer = DispatchTimer()
    let workQueue = DispatchQueue(label: "com.poviokit.tests.dispatch-timer", attributes: .concurrent)
    let done = expectation(description: "Concurrent access finished")
    done.expectedFulfillmentCount = 40
    
    for _ in 0..<20 {
      workQueue.async {
        timer.schedule(interval: .milliseconds(50), repeating: false, on: .main, nil)
        done.fulfill()
      }
      workQueue.async {
        timer.stop()
        done.fulfill()
      }
    }
    
    wait(for: [done], timeout: 2.0)
    timer.stop()
    XCTAssertFalse(timer.isActive, "Timer should be inactive after explicit stop")
  }
}

/// Thread-safe integer counter for observing test output from `@Sendable` closures.
private final class TimerCounter: @unchecked Sendable {
  private let lock = NSLock()
  private var count = 0
  
  @discardableResult
  func increment() -> Int {
    lock.withLock {
      count += 1
      return count
    }
  }
}

/// Thread-safe boolean flag for observing test output from `@Sendable` closures.
private final class TimerFlag: @unchecked Sendable {
  private let lock = NSLock()
  private var flag = false
  
  func set() { lock.withLock { flag = true } }
  
  var isSet: Bool { lock.withLock { flag } }
}
