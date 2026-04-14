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
}
