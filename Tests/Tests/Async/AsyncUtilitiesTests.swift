//
//  AsyncUtilitiesTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitAsync

private enum RaceTestError: Error, Equatable {
  case failed
}

@Sendable private func alwaysFailingOperation() async throws -> Int {
  throw RaceTestError.failed
}

final class AsyncUtilitiesTests: XCTestCase {
  private actor AttemptCounter {
    private(set) var value: Int = 0

    func increment() -> Int {
      value += 1
      return value
    }
  }

  private enum TestError: Error, Equatable {
    case failed
    case nonRetryable
  }

  func testRetrySucceedsAfterTransientFailures() async throws {
    let attempts = AttemptCounter()
    let result = try await retry(
      policy: .init(maxAttempts: 5, initialDelay: .milliseconds(1), backoffFactor: 2)
    ) {
      let current = await attempts.increment()
      if current < 3 {
        throw TestError.failed
      }
      return current
    }

    XCTAssertEqual(result, 3)
    let count = await attempts.value
    XCTAssertEqual(count, 3)
  }

  func testRetryThrowsAfterMaxAttempts() async {
    let attempts = AttemptCounter()

    do {
      _ = try await retry(
        policy: .init(maxAttempts: 3, initialDelay: .milliseconds(1))
      ) {
        _ = await attempts.increment()
        throw TestError.failed
      }
      XCTFail("Expected retry to throw when all attempts fail")
    } catch {
      XCTAssertTrue(error is TestError)
    }

    let count = await attempts.value
    XCTAssertEqual(count, 3)
  }

  func testRetryStopsWhenPredicateReturnsFalse() async {
    let attempts = AttemptCounter()

    do {
      _ = try await retry(
        policy: .init(maxAttempts: 5, initialDelay: .milliseconds(1)),
        shouldRetry: { !($0 is TestError) }
      ) {
        _ = await attempts.increment()
        throw TestError.nonRetryable
      }
      XCTFail("Expected non-retryable error to be rethrown")
    } catch {
      XCTAssertEqual(error as? TestError, .nonRetryable)
    }

    let count = await attempts.value
    XCTAssertEqual(count, 1)
  }

  func testWithTimeoutReturnsValueWhenOperationCompletesInTime() async throws {
    let value = try await withTimeout(.milliseconds(100)) {
      try await Task.sleep(for: .milliseconds(10))
      return 42
    }

    XCTAssertEqual(value, 42)
  }

  func testWithTimeoutThrowsWhenDeadlineExpires() async {
    do {
      _ = try await withTimeout(.milliseconds(1)) {
        try await Task.sleep(for: .seconds(5))
        return 1
      }
      XCTFail("Expected timeout error")
    } catch {
      XCTAssertEqual(error as? AsyncTimeoutError, .timedOut)
    }
  }

  func testMakeAsyncStreamBuildsValuePipeline() async throws {
    let pipe = makeAsyncStream() as AsyncStreamPipe<Int>

    pipe.continuation.yield(1)
    pipe.continuation.yield(2)
    pipe.continuation.finish()

    var values: [Int] = []
    for await value in pipe.stream {
      values.append(value)
    }

    XCTAssertEqual(values, [1, 2])
  }

  func testMakeAsyncThrowingStreamPropagatesFailure() async {
    enum LocalError: Error, Equatable {
      case boom
    }

    let pipe = makeAsyncThrowingStream() as AsyncThrowingStreamPipe<Int>
    pipe.continuation.yield(1)
    pipe.continuation.finish(throwing: LocalError.boom)

    var iterator = pipe.stream.makeAsyncIterator()

    do {
      let first = try await iterator.next()
      XCTAssertEqual(first, 1)
      _ = try await iterator.next()
      XCTFail("Expected stream failure")
    } catch {
      XCTAssertEqual(error as? LocalError, .boom)
    }
  }

  func testRaceReturnsFastestResult() async throws {
    let value = try await race(
      {
        try await Task.sleep(for: .milliseconds(80))
        return 1
      },
      {
        try await Task.sleep(for: .milliseconds(10))
        return 2
      }
    )

    XCTAssertEqual(value, 2)
  }

  func testRaceThrowsWhenFastestOperationFails() async {
    do {
      _ = try await race(
        alwaysFailingOperation,
        {
          try await Task.sleep(for: .milliseconds(40))
          return 42
        }
      )
      XCTFail("Expected race to throw first error")
    } catch {
      XCTAssertEqual(error as? RaceTestError, .failed)
    }
  }

  func testRaceThrowsOnEmptyOperations() async {
    do {
      let _: Int = try await race([])
      XCTFail("Expected race([]) to throw RaceError.noOperations")
    } catch {
      XCTAssertEqual(error as? RaceError, .noOperations)
    }
  }

  // MARK: - Backoff cap

  /// `policy.maxDelay` must cap the exponential growth so retries do
  /// not keep doubling indefinitely on long-running flaky operations.
  func testRetryBackoffIsCappedAtMaxDelay() async throws {
    let attempts = AttemptCounter()
    let clock = TestClock()

    let task = Task<Result<Int, Error>, Never> {
      do {
        let value: Int = try await retry(
          policy: .init(
            maxAttempts: 4,
            initialDelay: .milliseconds(20),
            backoffFactor: 10,
            maxDelay: .milliseconds(30)
          ),
          clock: clock
        ) {
          _ = await attempts.increment()
          throw TestError.failed
        }
        return .success(value)
      } catch {
        return .failure(error)
      }
    }

    // 4 attempts => 3 back-off sleeps. Drive the virtual clock through each
    // one deterministically; no wall-clock time elapses.
    for _ in 0..<3 {
      await clock.waitForSleepers(count: 1)
      await clock.run()
    }

    switch await task.value {
    case .success(let value):
      XCTFail("Expected retry to throw after exhausting attempts, got \(value)")
    case .failure(let error):
      XCTAssertEqual(error as? TestError, .failed)
    }

    // Without the cap the delays would be 20ms, 200ms, 2_000ms.
    // With `maxDelay: 30ms` they collapse to exactly 20ms, 30ms, 30ms.
    XCTAssertEqual(
      clock.requestedSleepDelays,
      [.milliseconds(20), .milliseconds(30), .milliseconds(30)],
      "delays did not respect maxDelay cap"
    )
    let count = await attempts.value
    XCTAssertEqual(count, 4)
  }

  // MARK: - Cancellation propagation

  /// External task cancellation must surface from `retry` as
  /// `CancellationError`, even while the helper is sleeping between
  /// attempts.
  func testRetryPropagatesCancellationDuringBackoff() async {
    let attempts = AttemptCounter()
    let task = Task<Result<Int, Error>, Never> {
      do {
        let value: Int = try await retry(
          policy: .init(maxAttempts: 5, initialDelay: .seconds(10))
        ) {
          _ = await attempts.increment()
          throw TestError.failed
        }
        return .success(value)
      } catch {
        return .failure(error)
      }
    }

    // Wait long enough that the first attempt has run and we are
    // sleeping in the back-off before the second attempt.
    try? await Task.sleep(for: .milliseconds(40))
    task.cancel()

    let result = await task.value
    switch result {
    case .success(let value):
      XCTFail("Expected CancellationError, got \(value)")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }
    let count = await attempts.value
    XCTAssertEqual(count, 1, "operation should not have been retried after cancellation")
  }

  /// The outer task being cancelled during `withTimeout` must surface
  /// as `CancellationError`, not as `AsyncTimeoutError.timedOut`.
  func testWithTimeoutPropagatesExternalCancellation() async {
    let task = Task<Result<Int, Error>, Never> {
      do {
        let value = try await withTimeout(.seconds(60)) {
          try await Task.sleep(for: .seconds(60))
          return 1
        }
        return .success(value)
      } catch {
        return .failure(error)
      }
    }

    try? await Task.sleep(for: .milliseconds(20))
    task.cancel()

    let result = await task.value
    switch result {
    case .success(let value):
      XCTFail("Expected CancellationError, got \(value)")
    case .failure(let error):
      XCTAssertTrue(error is CancellationError, "Expected CancellationError, got \(error)")
    }
  }

  /// `race` must propagate the operation's own thrown error, not a
  /// `CancellationError`, when the operation throws a domain error.
  func testRaceSurfacesOperationErrorWhenAllOperationsFail() async {
    enum BoomError: Error, Equatable { case slow, fast }

    do {
      let _: Int = try await race(
        {
          try await Task.sleep(for: .milliseconds(40))
          throw BoomError.slow
        },
        {
          try await Task.sleep(for: .milliseconds(10))
          throw BoomError.fast
        }
      )
      XCTFail("Expected race to throw")
    } catch {
      XCTAssertEqual(error as? BoomError, .fast)
    }
  }

  // MARK: - Default policy

  /// Documents the shipped default for ``AsyncRetryPolicy`` so any
  /// future tweak of the defaults (which is a behavioral change for
  /// every consumer) is forced through a test update.
  func testDefaultRetryPolicyValues() {
    let policy = AsyncRetryPolicy()
    XCTAssertEqual(policy.maxAttempts, 3)
    XCTAssertEqual(policy.initialDelay, .zero)
    XCTAssertEqual(policy.backoffFactor, 1)
    XCTAssertNil(policy.maxDelay)
    XCTAssertEqual(policy.jitter, .zero)
  }

  func testRetryPolicyClampsInvalidInputs() {
    let policy = AsyncRetryPolicy(
      maxAttempts: 0,
      initialDelay: .milliseconds(-100),
      backoffFactor: 0,
      maxDelay: .milliseconds(-50),
      jitter: .milliseconds(-1)
    )
    XCTAssertEqual(policy.maxAttempts, 1)
    XCTAssertEqual(policy.initialDelay, .zero)
    XCTAssertEqual(policy.backoffFactor, 1)
    XCTAssertEqual(policy.maxDelay, .zero)
    XCTAssertEqual(policy.jitter, .zero)
  }
}
