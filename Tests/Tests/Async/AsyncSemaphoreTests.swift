//
//  AsyncSemaphoreTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitAsync

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
    let gate = Latch()

    // Each task holds its permit (blocked on the gate) until we have
    // observed the permitted number running concurrently — no fixed sleep.
    let runner = Task {
      try await withThrowingTaskGroup(of: Void.self) { group in
        for _ in 0 ..< 10 {
          group.addTask {
            try await semaphore.withPermit {
              await probe.begin()
              await gate.wait()
              await probe.end()
            }
          }
        }
        try await group.waitForAll()
      }
    }

    // Exactly two permits, so concurrency saturates at two and stays there.
    await waitUntil { await probe.running == 2 }
    let observedMax = await probe.maxRunning
    XCTAssertEqual(observedMax, 2)

    await gate.open()
    try await runner.value
    let finalMax = await probe.maxRunning
    XCTAssertEqual(finalMax, 2)
  }

  // MARK: - Cancellation

  /// Regression test: a task suspended in `waitUnlessCancelled()` must
  /// surface `CancellationError` promptly when its parent task is
  /// cancelled — not hang waiting for a `release()` that may never
  /// come.
  func testWaitUnlessCancelledHonorsCancellationWhileSuspended() async throws {
    // All permits exhausted up-front so the test task is forced to
    // suspend in the waiter queue.
    let semaphore = AsyncSemaphore(value: 1)
    try await semaphore.waitUnlessCancelled()

    let task = Task<Result<Void, Error>, Never> {
      do {
        try await semaphore.waitUnlessCancelled()
        return .success(())
      } catch {
        return .failure(error)
      }
    }

    // Wait until the task is genuinely enqueued as a waiter.
    await waitUntil { semaphore.waiterCount == 1 }
    task.cancel()

    let result = await task.value
    switch result {
    case .success:
      XCTFail("Expected CancellationError, got success")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }

    // The cancelled waiter must not consume a permit, so a fresh
    // waiter can run as soon as the original holder releases.
    semaphore.release()
    try await semaphore.waitUnlessCancelled()
    semaphore.release()
  }

  /// Cancelling a task whose parent was already cancelled before
  /// reaching `waitUnlessCancelled()` must throw immediately and never
  /// touch the waiter queue.
  func testWaitUnlessCancelledThrowsImmediatelyWhenAlreadyCancelled() async throws {
    let semaphore = AsyncSemaphore(value: 0)

    let task = Task<Result<Void, Error>, Never> {
      // Cancel ourselves before suspending so the early
      // `Task.checkCancellation()` in `waitUnlessCancelled` fires.
      withUnsafeCurrentTask { $0?.cancel() }
      do {
        try await semaphore.waitUnlessCancelled()
        return .success(())
      } catch {
        return .failure(error)
      }
    }

    let result = await task.value
    switch result {
    case .success:
      XCTFail("Expected CancellationError, got success")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }
  }

  /// `withPermit` must not retain the permit when the surrounding
  /// task is cancelled before a permit was granted.
  func testWithPermitDoesNotLeakPermitOnCancellationWhileWaiting() async throws {
    let semaphore = AsyncSemaphore(value: 1)
    try await semaphore.waitUnlessCancelled() // exhaust

    let task = Task<Result<Void, Error>, Never> {
      do {
        try await semaphore.withPermit {
          XCTFail("operation must not run when permit acquisition is cancelled")
        }
        return .success(())
      } catch {
        return .failure(error)
      }
    }

    await waitUntil { semaphore.waiterCount == 1 }
    task.cancel()

    let result = await task.value
    switch result {
    case .success:
      XCTFail("Expected CancellationError, got success")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }

    // Original holder releases its single permit; a fresh acquire
    // must succeed without a second `release()` from the cancelled
    // task. If that task had leaked a permit, this would either hang
    // (no permit available) or succeed-and-leave-state-broken.
    semaphore.release()
    try await semaphore.waitUnlessCancelled()
    semaphore.release()
  }

  // MARK: - Initial value clamping

  func testInitialValueZeroBlocksUntilRelease() async throws {
    let semaphore = AsyncSemaphore(value: 0)

    let acquired = expectation(description: "permit acquired after release")
    let task = Task {
      try await semaphore.waitUnlessCancelled()
      acquired.fulfill()
    }

    // Confirm the task is genuinely waiting — not merely racing the
    // expectation.
    await waitUntil { semaphore.waiterCount == 1 }
    XCTAssertFalse(task.isCancelled)

    semaphore.release()
    await fulfillment(of: [acquired], timeout: 1)
    try await task.value
  }

  func testNegativeInitialValueIsClampedToZero() async throws {
    let semaphore = AsyncSemaphore(value: -5)
    let acquired = expectation(description: "permit acquired after release")

    let task = Task {
      try await semaphore.waitUnlessCancelled()
      acquired.fulfill()
    }

    await waitUntil { semaphore.waiterCount == 1 }
    XCTAssertFalse(task.isCancelled)
    semaphore.release()

    await fulfillment(of: [acquired], timeout: 1)
    try await task.value
  }

  // MARK: - FIFO ordering

  /// Waiters must be served in submission order.
  func testWaitersResumeInFIFOOrder() async throws {
    let semaphore = AsyncSemaphore(value: 1)
    try await semaphore.waitUnlessCancelled() // exhaust

    actor Recorder {
      private(set) var values: [Int] = []
      func append(_ value: Int) { values.append(value) }
    }
    let recorder = Recorder()

    var tasks: [Task<Void, Error>] = []
    for index in 0 ..< 5 {
      tasks.append(
        Task {
          try await semaphore.waitUnlessCancelled()
          await recorder.append(index)
          semaphore.release()
        }
      )
      // Ensure this waiter is enqueued before submitting the next, so the
      // queue order — and therefore FIFO service order — is deterministic.
      await waitUntil { semaphore.waiterCount == index + 1 }
    }

    semaphore.release()
    for task in tasks {
      try await task.value
    }

    let values = await recorder.values
    XCTAssertEqual(values, [0, 1, 2, 3, 4])
  }
}
