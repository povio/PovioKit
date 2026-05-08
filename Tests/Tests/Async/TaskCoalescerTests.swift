//
//  TaskCoalescerTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class TaskCoalescerTests: XCTestCase {
  private actor Counter {
    private(set) var count: Int = 0

    func increment() -> Int {
      count += 1
      return count
    }
  }

  func testCoalescerRunsOperationOnlyOncePerKey() async throws {
    let coalescer = TaskCoalescer<String, Int>()
    let counter = Counter()

    let results = try await withThrowingTaskGroup(of: Int.self) { group in
      for _ in 0 ..< 8 {
        group.addTask {
          try await coalescer.value(for: "shared-key") {
            _ = await counter.increment()
            try await Task.sleep(for: .milliseconds(30))
            return 7
          }
        }
      }

      var values: [Int] = []
      for try await value in group {
        values.append(value)
      }
      return values
    }

    XCTAssertEqual(results, Array(repeating: 7, count: 8))
    let invocationCount = await counter.count
    XCTAssertEqual(invocationCount, 1)
  }

  func testCancelValueCancelsInFlightOperationAndAllowsResubmission() async throws {
    let coalescer = TaskCoalescer<String, Int>()

    // Kick off a long-running coalesced task. It should observe cancellation
    // when we call `cancelValue(for:)` below.
    let firstCall = Task<Result<Int, Error>, Never> {
      do {
        let value = try await coalescer.value(for: "key") {
          try await Task.sleep(for: .seconds(10))
          return 1
        }
        return .success(value)
      } catch {
        return .failure(error)
      }
    }

    // Give the coalescer time to register the in-flight task.
    try await Task.sleep(for: .milliseconds(20))
    await coalescer.cancelValue(for: "key")

    let firstResult = await firstCall.value
    switch firstResult {
    case .success(let value):
      XCTFail("Expected cancelled operation to throw, got value \(value)")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }

    // After cancellation the slot must be free for a fresh submission.
    let second = try await coalescer.value(for: "key") {
      return 42
    }
    XCTAssertEqual(second, 42)
  }

  func testCancelAllCancelsEveryOutstandingOperation() async throws {
    let coalescer = TaskCoalescer<String, Int>()

    func launch(_ key: String) -> Task<Result<Int, Error>, Never> {
      Task<Result<Int, Error>, Never> {
        do {
          let value = try await coalescer.value(for: key) {
            try await Task.sleep(for: .seconds(10))
            return 0
          }
          return .success(value)
        } catch {
          return .failure(error)
        }
      }
    }

    let a = launch("a")
    let b = launch("b")
    let c = launch("c")

    try await Task.sleep(for: .milliseconds(20))
    await coalescer.cancelAll()

    for task in [a, b, c] {
      let result = await task.value
      guard case .failure(let error) = result else {
        XCTFail("Expected cancelled operation to throw")
        return
      }
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }

    // All slots are free; a resubmission for any of the cancelled keys runs
    // cleanly.
    let resubmitted = try await coalescer.value(for: "a") { 1 }
    XCTAssertEqual(resubmitted, 1)
  }
}
