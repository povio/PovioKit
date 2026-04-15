//
//  AsyncSemaphoreTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

final class AsyncSemaphoreTests: XCTestCase {
  private actor ConcurrencyProbe {
    private(set) var running: Int = 0
    private(set) var maxRunning: Int = 0

    func begin() {
      running += 1
      maxRunning = max(maxRunning, running)
    }

    func end() {
      running -= 1
    }
  }

  func testSemaphoreLimitsConcurrency() async throws {
    let semaphore = AsyncSemaphore(value: 2)
    let probe = ConcurrencyProbe()

    try await withThrowingTaskGroup(of: Void.self) { group in
      for _ in 0 ..< 10 {
        group.addTask {
          try await semaphore.withPermit {
            await probe.begin()
            try await Task.sleep(for: .milliseconds(20))
            await probe.end()
          }
        }
      }
      try await group.waitForAll()
    }

    let maxRunning = await probe.maxRunning
    XCTAssertLessThanOrEqual(maxRunning, 2)
  }
}
