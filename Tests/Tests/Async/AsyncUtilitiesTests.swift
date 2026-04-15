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
}
