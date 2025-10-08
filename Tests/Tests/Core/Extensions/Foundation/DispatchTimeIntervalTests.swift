//
//  DispatchTimeIntervalTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest

class DispatchTimeIntervalTests: XCTestCase {
  func testTimeInterval() {
    let dispatchInterval: DispatchTimeInterval = .seconds(5)
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, 5)
  }
  
  func test_timeInterval_returnsTimeIntervalWithMilliSeconds() {
    let dispatchInterval: DispatchTimeInterval = .milliseconds(5_000)
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, 5)
  }
  
  func test_timeInterval_returnsTimeIntervalWithMicroSeconds() {
    let dispatchInterval: DispatchTimeInterval = .microseconds(5_000_000)
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, 5)
  }
  
  func test_timeInterval_returnsTimeIntervalWithNanoseconds() {
    let dispatchInterval: DispatchTimeInterval = .nanoseconds(5_000_000_000)
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, 5)
  }
  
  func test_timeInterval_returnsTimeIntervalWithNever() {
    let dispatchInterval: DispatchTimeInterval = .never
    let timeInterval = dispatchInterval.timeInterval
    XCTAssertEqual(timeInterval, .infinity)
  }
}
