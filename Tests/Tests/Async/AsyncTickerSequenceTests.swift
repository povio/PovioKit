//
//  AsyncTickerSequenceTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncTickerSequenceTests: XCTestCase {
  // MARK: - Deterministic tests (TestClock)

  func testTickerProducesTicksAtGivenInterval() async throws {
    let clock = TestClock()
    let ticker = AsyncTickerSequence(
      clock: clock,
      interval: .milliseconds(40),
      // A non-zero initial delay forces the first tick through the clock's
      // sleep path so the test observes the interval deterministically.
      initialDelay: .milliseconds(40)
    )

    // The iterator's `next()` is mutating, so owning it inside a single Task
    // keeps all mutations isolated to one concurrency domain (required by
    // Swift 6). The test drives the clock from the outside and collects the
    // resulting ticks via the task's return value.
    let ticks = Task { () -> (TestClock.Instant?, TestClock.Instant?) in
      var iterator = ticker.makeAsyncIterator()
      let first = try await iterator.next()
      let second = try await iterator.next()
      return (first, second)
    }

    await clock.waitForSleepers(count: 1)
    await clock.advance(by: .milliseconds(40))
    await clock.waitForSleepers(count: 1)
    await clock.advance(by: .milliseconds(40))

    let (first, second) = try await ticks.value
    let firstInstant = try XCTUnwrap(first)
    let secondInstant = try XCTUnwrap(second)
    XCTAssertEqual(firstInstant.duration(to: secondInstant), .milliseconds(40))
  }

  func testTickerRespectsInitialDelay() async throws {
    let clock = TestClock()
    let ticker = AsyncTickerSequence(
      clock: clock,
      interval: .milliseconds(10),
      initialDelay: .milliseconds(80)
    )

    let tick = Task { () -> TestClock.Instant? in
      var iterator = ticker.makeAsyncIterator()
      return try await iterator.next()
    }

    await clock.waitForSleepers(count: 1)

    // Advancing by less than `initialDelay` must not produce a tick.
    await clock.advance(by: .milliseconds(50))
    await clock.advance(by: .milliseconds(29))

    // The final millisecond must finally release the first tick.
    await clock.advance(by: .milliseconds(1))
    let first = try await tick.value

    let instant = try XCTUnwrap(first)
    XCTAssertEqual(instant.offset, .milliseconds(80))
  }

  /// The ticker advances `nextTick` from the previous `nextTick`, not from
  /// `clock.now`, so a slow consumer doesn't cause the interval to drift.
  /// This test jumps past several intervals in a single advance and asserts
  /// the emitted ticks still land on the logical grid.
  func testTickerDoesNotDriftAcrossLateConsumption() async throws {
    let clock = TestClock()
    let ticker = AsyncTickerSequence(
      clock: clock,
      interval: .milliseconds(20),
      initialDelay: .milliseconds(20)
    )
    // Skip well past three intervals in a single advance; the ticker must
    // still emit on the 20/40/60ms grid. Once the clock has jumped ahead,
    // subsequent `sleep(until:)` calls resume immediately, so all three
    // ticks are produced inside the same task.
    let ticks = Task { () -> (TestClock.Instant?, TestClock.Instant?, TestClock.Instant?) in
      var iterator = ticker.makeAsyncIterator()
      let a = try await iterator.next()
      let b = try await iterator.next()
      let c = try await iterator.next()
      return (a, b, c)
    }

    await clock.waitForSleepers(count: 1)
    await clock.advance(by: .milliseconds(200))

    let (firstValue, secondValue, thirdValue) = try await ticks.value
    let first = try XCTUnwrap(firstValue)
    let second = try XCTUnwrap(secondValue)
    let third = try XCTUnwrap(thirdValue)

    XCTAssertEqual(first.offset, .milliseconds(20))
    XCTAssertEqual(second.offset, .milliseconds(40))
    XCTAssertEqual(third.offset, .milliseconds(60))
  }
}
