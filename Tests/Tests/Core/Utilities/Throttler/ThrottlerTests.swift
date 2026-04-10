//
//  ThrottlerTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
@testable import PovioKitUtilities

class ThrottlerTests: XCTestCase {
  func testShouldExecuteWhenDelayed() {
    let delay = 10
    let waiting = delay + 500
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {
      expectation.fulfill()
    }
    XCTAssertEqual(throttler.outputIdentifiers, [])
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["A"])
  }
  
  func testShouldNotExecuteWhenCanceled() {
    let delay = 10
    let waiting = delay + 50
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute { }
    throttler.cancelPendingJob()
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(waiting)) {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, [])
  }
  
  func testShouldSkipExecutionWhenThereIsAnotherOne() {
    let delay = 10
    let waiting = delay + 500
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {}
    throttler.execute(withId: "B") {
      expectation.fulfill()
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["B"])
  }
  
  func testShouldExecuteTwiceWhenTwoSequentialCalls() {
    let delay = 10
    let waiting = 2 * delay + 500
    let throttler = MockedThrottler(delay: .milliseconds(delay))
    let expectation = self.expectation(description: "delay")
    throttler.execute(withId: "A") {
      throttler.execute(withId: "B") {
        expectation.fulfill()
      }
    }
    waitForExpectations(timeout: Double(waiting) / 1000, handler: nil)
    XCTAssertEqual(throttler.outputIdentifiers, ["A", "B"])
  }
  
  func testExecuteWithResultReturnsComputedValue() {
    let throttler = Throttler(queue: .main, delay: .milliseconds(10))
    let expectation = self.expectation(description: "executeWithResult")
    var capturedResult: Int?
    
    throttler.executeWithResult(work: { 40 + 2 }) { result in
      capturedResult = result
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1.0, handler: nil)
    XCTAssertEqual(capturedResult, 42)
  }
}

private class MockedThrottler: Throttler {
  var outputIdentifiers: [String] = []
  
  func execute(withId id: String, completion: @escaping () -> Void) {
    execute {
      self.outputIdentifiers.append(id)
      completion()
    }
  }
  
  func execute(withId id: String, completion: @escaping () -> Void, expectedCompletion: @escaping () -> Void) {
    execute(withId: id, completion: completion)
    execute {
      self.outputIdentifiers.append(id)
      completion()
    }
  }
}
