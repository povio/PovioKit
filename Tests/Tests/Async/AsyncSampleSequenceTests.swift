//
//  AsyncSampleSequenceTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncSampleSequenceTests: XCTestCase {
  // MARK: - Test helpers

  /// Base sequence that emits values after sleeping on a caller-supplied
  /// `Clock`, so the driving test can pair it with `TestClock` and
  /// deterministically advance virtual time between emissions.
  private struct ClockDrivenValuesSequence<C: Clock>: AsyncSequence where C.Duration == Duration {
    typealias Element = Int

    let values: [Int]
    let delayBetweenValues: Duration
    let clock: C

    struct AsyncIterator: AsyncIteratorProtocol {
      let values: [Int]
      let delayBetweenValues: Duration
      let clock: C
      var index: Int = 0

      mutating func next() async throws -> Int? {
        guard index < values.count else { return nil }
        try await clock.sleep(until: clock.now.advanced(by: delayBetweenValues), tolerance: nil)
        defer { index += 1 }
        return values[index]
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      .init(values: values, delayBetweenValues: delayBetweenValues, clock: clock)
    }
  }

  // MARK: - Deterministic tests (TestClock)

  func testSampleEmitsOnlyLatestValueFromBurst() async throws {
    let clock = TestClock()
    // `delayBetweenValues: .zero` makes every `baseIterator.next()` call
    // resume on the same virtual instant, so all four values arrive in a
    // single burst and the sampler should coalesce them to the last one.
    let base = ClockDrivenValuesSequence(
      values: [1, 2, 3, 4],
      delayBetweenValues: .zero,
      clock: clock
    )
    let sampled = base.sample(
      clock: clock,
      delayBetweenElements: .milliseconds(50)
    )

    let result = Task { () -> (Int?, Int?) in
      let iterator = sampled.makeAsyncIterator()
      let first = try await iterator.next()
      let second = try await iterator.next()
      return (first, second)
    }

    // Drain the burst and then release the end-of-source trailing window.
    // The sampler registers exactly one sleeper when it hits the closing
    // `Task.sleep(until: emitAt, clock:)` after the base is exhausted.
    await clock.waitForSleepers(count: 1)
    await clock.advance(by: .milliseconds(50))

    let (first, second) = try await result.value
    XCTAssertEqual(first, 4)
    XCTAssertNil(second)
  }

  func testSampleEmitsAllWhenValuesAreSpacedOut() async throws {
    let clock = TestClock()
    let base = ClockDrivenValuesSequence(
      values: [1, 2, 3],
      delayBetweenValues: .milliseconds(200),
      clock: clock
    )
    let sampled = base.sample(
      clock: clock,
      delayBetweenElements: .milliseconds(20)
    )

    let result = Task { () -> [Int] in
      var received: [Int] = []
      for try await value in sampled {
        received.append(value)
      }
      return received
    }

    // Each 200ms advance releases the next base value. Between each pair
    // the sampler observes `duration >= delayBetweenElements` and emits
    // the previous value. After the base ends, it waits out one more
    // `delayBetweenElements` window before emitting the final value.
    for _ in 0..<3 {
      await clock.waitForSleepers(count: 1)
      await clock.advance(by: .milliseconds(200))
    }
    // Trailing window after the base is exhausted.
    await clock.waitForSleepers(count: 1)
    await clock.advance(by: .milliseconds(20))

    let received = try await result.value
    XCTAssertEqual(received, [1, 2, 3])
  }

  // MARK: - Non-timing edge cases

  func testSampleReturnsNilForEmptyBaseSequence() async throws {
    let clock = TestClock()
    let base = ClockDrivenValuesSequence(
      values: [],
      delayBetweenValues: .zero,
      clock: clock
    )
    let sampled = base.sample(
      clock: clock,
      delayBetweenElements: .milliseconds(50)
    )

    let iterator = sampled.makeAsyncIterator()
    let first = try await iterator.next()
    XCTAssertNil(first)
  }

  func testSampleRespectsTaskCancellation() async throws {
    // Cancellation is exercised against the real suspending clock because
    // `TestClock` has no notion of scheduler-driven cancellation — the
    // goal here is to prove that a cancelled consumer task unwinds cleanly
    // while the sampler is sleeping, regardless of the clock in use.
    struct NeverSequence: AsyncSequence {
      typealias Element = Int

      struct AsyncIterator: AsyncIteratorProtocol {
        mutating func next() async throws -> Int? {
          try await Task.sleep(for: .seconds(60))
          return nil
        }
      }

      func makeAsyncIterator() -> AsyncIterator { .init() }
    }

    let sampled = NeverSequence().sample(
      clock: .suspending,
      delayBetweenElements: .milliseconds(10)
    )

    let task = Task<Int?, Error> {
      let iterator = sampled.makeAsyncIterator()
      return try await iterator.next()
    }

    // Give the task a moment to enter the sleep before cancelling.
    try await Task.sleep(for: .milliseconds(20))
    task.cancel()

    do {
      _ = try await task.value
      XCTFail("Expected CancellationError to propagate from cancelled consumer task.")
    } catch is CancellationError {
      // expected
    }
  }
}
