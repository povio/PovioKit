//
//  DebouncerTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitUtilities

final class DebouncerTests: XCTestCase {
  // MARK: - Trailing

  func testTrailingBehaviorExecutesOnlyLastCall() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "Trailing call executed")
    let output = LockedArray<String>()

    debouncer.execute { output.append("A") }
    debouncer.execute {
      output.append("B")
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(output.snapshot, ["B"])
  }

  func testTrailingBehaviorExecutesTwiceWhenCallsAreSpacedApart() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .trailing)
    let first = expectation(description: "First trailing call executed")
    let second = expectation(description: "Second trailing call executed")
    let output = LockedArray<String>()

    debouncer.execute {
      output.append("A")
      first.fulfill()
    }

    wait(for: [first], timeout: 1)

    debouncer.execute {
      output.append("B")
      second.fulfill()
    }

    wait(for: [second], timeout: 1)
    XCTAssertEqual(output.snapshot, ["A", "B"])
  }

  func testTrailingBehaviorSupportsRescheduleFromCallback() {
    // Regression test: calling `execute` from inside a trailing callback
    // used to deadlock when the debouncer held its lock across the work
    // closure.
    let debouncer = Debouncer(delay: .milliseconds(10), behavior: .trailing)
    let done = expectation(description: "Second call completed")
    let output = LockedArray<String>()

    debouncer.execute {
      output.append("A")
      debouncer.execute {
        output.append("B")
        done.fulfill()
      }
    }

    wait(for: [done], timeout: 1)
    XCTAssertEqual(output.snapshot, ["A", "B"])
  }

  // MARK: - Leading

  func testLeadingBehaviorExecutesFirstCallOnlyWithinWindow() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .leading)
    let leading = expectation(description: "Leading call executed")
    let output = LockedArray<String>()

    debouncer.execute {
      output.append("A")
      leading.fulfill()
    }
    debouncer.execute { output.append("B") }

    wait(for: [leading], timeout: 1)

    let settle = expectation(description: "Wait for debounce window")
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80)) {
      settle.fulfill()
    }
    wait(for: [settle], timeout: 1)

    XCTAssertEqual(output.snapshot, ["A"])
  }

  // MARK: - Leading and trailing

  func testLeadingAndTrailingBehaviorExecutesBothWhenBurstContinues() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .leadingAndTrailing)
    let expectation = expectation(description: "Leading and trailing executed")
    expectation.expectedFulfillmentCount = 2
    let output = LockedArray<String>()

    debouncer.execute {
      output.append("A")
      expectation.fulfill()
    }
    debouncer.execute {
      output.append("B")
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(output.snapshot, ["A", "B"])
  }

  // MARK: - Cancel

  func testCancelPendingJobPreventsTrailingExecution() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "No execution after cancel")
    let output = LockedArray<String>()

    debouncer.execute { output.append("A") }
    debouncer.cancel()

    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(80)) {
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertTrue(output.snapshot.isEmpty)
  }

  // MARK: - executeWithResult

  func testExecuteWithResultReturnsValue() {
    let debouncer = Debouncer(delay: .milliseconds(20), behavior: .trailing)
    let expectation = expectation(description: "Result callback executed")
    let box = LockedBox<Int>()

    debouncer.executeWithResult(work: { 21 * 2 }) { result in
      box.set(result)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1)
    XCTAssertEqual(box.value, 42)
  }
}

// MARK: - Test helpers

/// Minimal `Sendable` container used to observe effects from debounced
/// closures without tripping strict-concurrency diagnostics.
private final class LockedArray<Element>: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: [Element] = []

  func append(_ element: Element) {
    lock.withLock { storage.append(element) }
  }

  var snapshot: [Element] {
    lock.withLock { storage }
  }
}

private final class LockedBox<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var storage: Value?

  func set(_ value: Value) {
    lock.withLock { storage = value }
  }

  var value: Value? {
    lock.withLock { storage }
  }
}
