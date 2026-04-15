//
//  DebouncerTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitUtilities

final class DebouncerTests: XCTestCase {
  func testTrailingBehaviorExecutesOnlyLastCall() {
    let debouncer = Debouncer(queue: .main, delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "Trailing call executed")
    var output = [String]()
    
    debouncer.execute { output.append("A") }
    debouncer.execute {
      output.append("B")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
    XCTAssertEqual(output, ["B"])
  }
  
  func testLeadingBehaviorExecutesFirstCallOnlyWithinWindow() {
    let debouncer = Debouncer(queue: .main, delay: .milliseconds(20), behavior: .leading)
    let leadingExpectation = expectation(description: "Leading call executed")
    var output = [String]()
    
    debouncer.execute {
      output.append("A")
      leadingExpectation.fulfill()
    }
    debouncer.execute { output.append("B") }
    
    waitForExpectations(timeout: 1)
    let settleExpectation = expectation(description: "Wait for debounce window")
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(60)) {
      settleExpectation.fulfill()
    }
    waitForExpectations(timeout: 1)
    
    XCTAssertEqual(output, ["A"])
  }
  
  func testLeadingAndTrailingBehaviorExecutesBothWhenBurstContinues() {
    let debouncer = Debouncer(queue: .main, delay: .milliseconds(20), behavior: .leadingAndTrailing)
    let expectation = expectation(description: "Leading and trailing executed")
    expectation.expectedFulfillmentCount = 2
    var output = [String]()
    
    debouncer.execute {
      output.append("A")
      expectation.fulfill()
    }
    debouncer.execute {
      output.append("B")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
    XCTAssertEqual(output, ["A", "B"])
  }
  
  func testCancelPendingJobPreventsTrailingExecution() {
    let debouncer = Debouncer(queue: .main, delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "No execution after cancel")
    var output = [String]()
    
    debouncer.execute { output.append("A") }
    debouncer.cancelPendingJob()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80)) {
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
    XCTAssertTrue(output.isEmpty)
  }
  
  func testExecuteWithResultReturnsValue() {
    let debouncer = Debouncer(queue: .main, delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "Result callback executed")
    var value: Int?
    
    debouncer.executeWithResult(work: { 21 * 2 }) { result in
      value = result
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 1)
    XCTAssertEqual(value, 42)
  }
}
