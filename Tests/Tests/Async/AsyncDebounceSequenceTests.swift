//
//  AsyncDebounceSequenceTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncDebounceSequenceTests: XCTestCase {
  private struct DelayedValuesSequence: AsyncSequence {
    typealias Element = Int

    let values: [Int]
    let delayBetweenValues: Duration

    struct AsyncIterator: AsyncIteratorProtocol {
      let values: [Int]
      let delayBetweenValues: Duration
      var index: Int = 0

      mutating func next() async throws -> Int? {
        guard index < values.count else { return nil }
        try await Task.sleep(for: delayBetweenValues)
        defer { index += 1 }
        return values[index]
      }
    }

    func makeAsyncIterator() -> AsyncIterator {
      .init(values: values, delayBetweenValues: delayBetweenValues)
    }
  }

  func testDebounceEmitsOnlyLatestValueFromBurst() async throws {
    let sequence = DelayedValuesSequence(values: [1, 2, 3, 4], delayBetweenValues: .milliseconds(10))
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenElements: .milliseconds(50)
    )

    let iterator = debounced.makeAsyncIterator()
    let first = try await iterator.next()
    let second = try await iterator.next()

    XCTAssertEqual(first, 4)
    XCTAssertNil(second)
  }

  func testDebounceEmitsAllWhenValuesAreSpacedOut() async throws {
    let sequence = DelayedValuesSequence(values: [1, 2, 3], delayBetweenValues: .milliseconds(80))
    let debounced = sequence.debounce(
      clock: .suspending,
      delayBetweenElements: .milliseconds(30)
    )

    var received: [Int] = []
    for try await value in debounced {
      received.append(value)
    }

    XCTAssertEqual(received, [1, 2, 3])
  }
}
