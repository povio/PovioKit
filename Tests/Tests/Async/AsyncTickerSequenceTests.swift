//
//  AsyncTickerSequenceTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncTickerSequenceTests: XCTestCase {
  func testTickerProducesTicksAtGivenInterval() async throws {
    let ticker = AsyncTickerSequence(
      clock: ContinuousClock(),
      interval: .milliseconds(40)
    )

    var iterator = ticker.makeAsyncIterator()
    guard let first = try await iterator.next() else {
      XCTFail("Expected first tick")
      return
    }
    guard let second = try await iterator.next() else {
      XCTFail("Expected second tick")
      return
    }

    let elapsed = second.duration(to: first) * -1
    XCTAssertGreaterThanOrEqual(elapsed, .milliseconds(35))
  }

  func testTickerRespectsInitialDelay() async throws {
    let start = ContinuousClock.now
    let ticker = AsyncTickerSequence(
      clock: ContinuousClock(),
      interval: .milliseconds(10),
      initialDelay: .milliseconds(80)
    )

    var iterator = ticker.makeAsyncIterator()
    guard try await iterator.next() != nil else {
      XCTFail("Expected first tick")
      return
    }
    let elapsed = ContinuousClock.now - start

    XCTAssertGreaterThanOrEqual(elapsed, .milliseconds(70))
  }
}
