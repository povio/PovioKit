//
//  AsyncThrottleSequenceTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncThrottleSequenceTests: XCTestCase {
  
  // MARK: - Test Sequence
  
  struct TestAsyncSequence: AsyncSequence {
    typealias Element = Int
    
    let values: [Int]
    let delay: Duration
    
    init(values: [Int], delay: Duration = .milliseconds(10)) {
      self.values = values
      self.delay = delay
    }
    
    struct AsyncIterator: AsyncIteratorProtocol {
      let values: [Int]
      let delay: Duration
      var index = 0
      
      mutating func next() async throws -> Int? {
        guard index < values.count else { return nil }
        try await Task.sleep(for: delay)
        let value = values[index]
        index += 1
        return value
      }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
      AsyncIterator(values: values, delay: delay)
    }
  }
  
  // MARK: - Basic Functionality Tests
  
  func testThrottleBasicFunctionality() async throws {
    let values = [1, 2, 3, 4, 5]
    let sequence = TestAsyncSequence(values: values)
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    var results: [Int] = []
    let iterator = throttled.makeAsyncIterator()
    
    while let value = try await iterator.next() {
      results.append(value)
    }
    
    XCTAssertEqual(results, values, "Should receive all values")
  }
  
  func testThrottleWithSingleValue() async throws {
    let sequence = TestAsyncSequence(values: [42])
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(100)
    )
    
    let iterator = throttled.makeAsyncIterator()
    let result = try await iterator.next()
    
    XCTAssertEqual(result, 42, "Should receive single value")
    
    let secondResult = try await iterator.next()
    XCTAssertNil(secondResult, "Should return nil after sequence ends")
  }
  
  func testThrottleWithEmptySequence() async throws {
    let sequence = TestAsyncSequence(values: [])
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    let iterator = throttled.makeAsyncIterator()
    let result = try await iterator.next()
    
    XCTAssertNil(result, "Empty sequence should return nil immediately")
  }
  
  // MARK: - Timing Tests
  
  func testThrottleActuallyDelays() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttleDelay: Duration = .milliseconds(100)
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: throttleDelay
    )
    
    let startTime = ContinuousClock.now
    let iterator = throttled.makeAsyncIterator()
    
    _ = try await iterator.next()
    let elapsedTime = ContinuousClock.now - startTime
    
    // Should take at least the throttle delay
    XCTAssertGreaterThanOrEqual(
      elapsedTime,
      throttleDelay,
      "Should delay for at least the specified duration"
    )
  }
  
  func testMultipleCallsWithDelay() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    let startTime = ContinuousClock.now
    let iterator = throttled.makeAsyncIterator()
    var count = 0
    
    while let _ = try await iterator.next() {
      count += 1
    }
    
    let totalTime = ContinuousClock.now - startTime
    let expectedMinimumTime = Duration.milliseconds(50) * 3 // 3 values * 50ms delay
    
    XCTAssertEqual(count, 3, "Should receive all 3 values")
    XCTAssertGreaterThanOrEqual(
      totalTime,
      expectedMinimumTime,
      "Total time should be at least sum of delays"
    )
  }
  
  // MARK: - Cancellation Tests
  
  func testThrottleCancellation() async throws {
    let values = Array(1...100) // Large sequence
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    var results: [Int] = []
    let task = Task {
      let iterator = throttled.makeAsyncIterator()
      while let value = try await iterator.next() {
        results.append(value)
        if results.count >= 3 {
          break // Stop early
        }
      }
    }
    
    try await task.value
    
    XCTAssertEqual(results.count, 3, "Should stop after collecting 3 values")
    XCTAssertLessThan(results.count, values.count, "Should not process all values")
  }
  
  // MARK: - Concurrent Access Tests
  
  func testMultipleIterators() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values)
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    // Create two separate iterators
    let iterator1 = throttled.makeAsyncIterator()
    let iterator2 = throttled.makeAsyncIterator()
    
    let value1 = try await iterator1.next()
    let value2 = try await iterator2.next()
    
    // Both should receive the first value independently
    XCTAssertEqual(value1, 1, "First iterator should get first value")
    XCTAssertEqual(value2, 1, "Second iterator should get first value")
  }
  
  // MARK: - Different Clock Types
  
  func testWithContinuousClock() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .continuous,
      delayBetweenTasks: .milliseconds(50)
    )
    
    var results: [Int] = []
    let iterator = throttled.makeAsyncIterator()
    
    while let value = try await iterator.next() {
      results.append(value)
    }
    
    XCTAssertEqual(results, values, "Should work with continuous clock")
  }
  
  func testWithSuspendingClock() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )
    
    var results: [Int] = []
    let iterator = throttled.makeAsyncIterator()
    
    while let value = try await iterator.next() {
      results.append(value)
    }
    
    XCTAssertEqual(results, values, "Should work with suspending clock")
  }
  
  // MARK: - Edge Cases
  
  func testZeroDelay() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(0)
    )
    
    var results: [Int] = []
    let iterator = throttled.makeAsyncIterator()
    
    while let value = try await iterator.next() {
      results.append(value)
    }
    
    XCTAssertEqual(results, values, "Should work with zero delay")
  }
  
  func testVeryLargeDelay() async throws {
    let values = [1]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let throttled = sequence.throttle(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(200)
    )
    
    let startTime = ContinuousClock.now
    let iterator = throttled.makeAsyncIterator()
    let result = try await iterator.next()
    let elapsed = ContinuousClock.now - startTime
    
    XCTAssertEqual(result, 1, "Should receive value even with large delay")
    XCTAssertGreaterThanOrEqual(elapsed, .milliseconds(200), "Should respect large delay")
  }
}

