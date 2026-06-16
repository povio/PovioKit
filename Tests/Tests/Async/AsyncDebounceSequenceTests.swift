//
//  AsyncDebounceSequenceTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncDebounceSequenceTests: XCTestCase {
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

  // MARK: - Basic Functionality

  func testDebounceBasicFunctionality() async throws {
    let values = [1, 2, 3, 4, 5]
    let sequence = TestAsyncSequence(values: values)
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )

    var results: [Int] = []
    let iterator = debounced.makeAsyncIterator()

    while let value = try await iterator.next() {
      results.append(value)
    }

    XCTAssertEqual(results, values)
  }

  func testDebounceWithSingleValue() async throws {
    let sequence = TestAsyncSequence(values: [42])
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(100)
    )

    let iterator = debounced.makeAsyncIterator()
    let first = try await iterator.next()
    let second = try await iterator.next()
    XCTAssertEqual(first, 42)
    XCTAssertNil(second)
  }

  func testDebounceWithEmptySequence() async throws {
    let sequence = TestAsyncSequence(values: [])
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )

    let iterator = debounced.makeAsyncIterator()
    let result = try await iterator.next()
    XCTAssertNil(result)
  }

  // MARK: - Timing

  func testDebounceActuallyDelays() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let delay: Duration = .milliseconds(100)
    let debounced = sequence.debounce(clock: .suspending, delayBetweenTasks: delay)

    let startTime = ContinuousClock.now
    let iterator = debounced.makeAsyncIterator()
    _ = try await iterator.next()
    let elapsed = ContinuousClock.now - startTime

    XCTAssertGreaterThanOrEqual(elapsed, delay)
  }

  // MARK: - Cancellation

  func testEarlyBreak() async throws {
    let values = Array(1...100)
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenTasks: .milliseconds(50)
    )

    var results: [Int] = []
    let iterator = debounced.makeAsyncIterator()
    while let value = try await iterator.next() {
      results.append(value)
      if results.count >= 3 { break }
    }

    XCTAssertEqual(results.count, 3)
  }

  // MARK: - Clock flavors

  func testWithContinuousClock() async throws {
    let values = [1, 2, 3]
    let sequence = TestAsyncSequence(values: values, delay: .milliseconds(0))
    let debounced = sequence.debounce(
      clock: .continuous,
      delayBetweenTasks: .milliseconds(20)
    )

    var results: [Int] = []
    let iterator = debounced.makeAsyncIterator()
    while let value = try await iterator.next() {
      results.append(value)
    }

    XCTAssertEqual(results, values)
  }

  // MARK: - Caller-driven cancellation propagates

  func testCallerCancellationPropagatesAsCancellationError() async throws {
    let sequence = TestAsyncSequence(values: [1, 2, 3], delay: .milliseconds(0))
    // Drive debouncing with a `TestClock` so we can detect — deterministically,
    // without a fixed sleep — when the iterator is actually suspended in its
    // debounce delay. The clock is never advanced, so the iterator stays
    // suspended until we cancel it.
    let clock = TestClock()
    let debounced = sequence.debounce(
      clock: clock,
      delayBetweenTasks: .milliseconds(500)
    )
    let iterator = debounced.makeAsyncIterator()

    let task = Task { () -> Result<Int?, Error> in
      do {
        let value = try await iterator.next()
        return .success(value)
      } catch {
        return .failure(error)
      }
    }

    // Wait until the iterator is genuinely sleeping on the clock, then cancel.
    await clock.waitForSleepers(count: 1)
    task.cancel()

    switch await task.value {
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "External cancellation should surface as CancellationError, got \(error)")
    case .success(let value):
      XCTFail("Expected CancellationError, got value: \(String(describing: value))")
    }
  }
}
