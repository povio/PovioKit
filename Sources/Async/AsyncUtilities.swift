//
//  AsyncUtilities.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// Error thrown by timeout helpers when the configured deadline is reached.
public enum AsyncTimeoutError: Error, Equatable {
  case timedOut
}

/// Configuration used by ``retry(policy:clock:operation:)``.
///
/// ## Example
/// ```swift
/// let policy = AsyncRetryPolicy(
///   maxAttempts: 4,
///   initialDelay: .milliseconds(200),
///   backoffFactor: 2,
///   maxDelay: .seconds(2)
/// )
/// ```
public struct AsyncRetryPolicy: Equatable, Sendable {
  /// Total number of attempts, including the first one.
  public let maxAttempts: Int
  /// Delay before the first retry attempt.
  public let initialDelay: Duration
  /// Integer backoff factor applied after every failed attempt.
  public let backoffFactor: Int
  /// Optional maximum delay cap for backoff growth.
  public let maxDelay: Duration?
  /// Additional random delay in `[0, jitter]` added before each retry.
  public let jitter: Duration

  public init(
    maxAttempts: Int = 3,
    initialDelay: Duration = .zero,
    backoffFactor: Int = 1,
    maxDelay: Duration? = nil,
    jitter: Duration = .zero
  ) {
    self.maxAttempts = max(1, maxAttempts)
    self.initialDelay = max(.zero, initialDelay)
    self.backoffFactor = max(1, backoffFactor)
    if let maxDelay {
      self.maxDelay = max(.zero, maxDelay)
    } else {
      self.maxDelay = nil
    }
    self.jitter = max(.zero, jitter)
  }
}

/// Executes an async operation with retries according to the supplied policy.
///
/// - Parameters:
///   - policy: Retry policy that controls attempts and delay growth.
///   - clock: Clock used for sleeping between retries.
///   - shouldRetry: Predicate that determines whether a thrown error is retryable.
///   - operation: Async operation to execute.
/// - Returns: Result returned by the first successful attempt.
/// - Throws: Last error produced by the operation if all attempts fail.
///
/// ## Example
/// ```swift
/// let user = try await retry(
///   policy: .init(maxAttempts: 3, initialDelay: .milliseconds(250), backoffFactor: 2),
///   clock: .suspending
/// ) {
///   try await apiClient.fetchUser()
/// }
/// ```
public func retry<R, C: Clock>(
  policy: AsyncRetryPolicy = .init(),
  clock: C,
  shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
  operation: @escaping @Sendable () async throws -> R
) async throws -> R where C.Duration == Duration {
  var nextDelay = policy.initialDelay

  for attempt in 1 ... policy.maxAttempts {
    do {
      return try await operation()
    } catch {
      guard attempt < policy.maxAttempts, shouldRetry(error) else {
        throw error
      }

      let jitterDelay = randomDuration(upTo: policy.jitter)
      let totalDelay = nextDelay + jitterDelay
      if totalDelay > .zero {
        try await Task.sleep(until: clock.now.advanced(by: totalDelay), clock: clock)
      }

      let grownDelay = nextDelay * policy.backoffFactor
      if let maxDelay = policy.maxDelay {
        nextDelay = min(grownDelay, maxDelay)
      } else {
        nextDelay = grownDelay
      }
    }
  }

  // This line is unreachable because maxAttempts is always at least 1.
  throw AsyncTimeoutError.timedOut
}

/// Executes an async operation with retries using `SuspendingClock`.
///
/// ## Example
/// ```swift
/// let config = try await retry(policy: .init(maxAttempts: 2)) {
///   try await configService.load()
/// }
/// ```
public func retry<R>(
  policy: AsyncRetryPolicy = .init(),
  shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
  operation: @escaping @Sendable () async throws -> R
) async throws -> R {
  try await retry(policy: policy, clock: .suspending, shouldRetry: shouldRetry, operation: operation)
}

/// Runs an async operation and throws if it doesn't finish before the timeout.
///
/// - Parameters:
///   - timeout: Maximum duration to wait for operation completion.
///   - clock: Clock used to evaluate timeout.
///   - operation: Async operation to run.
/// - Returns: Result returned by the operation.
/// - Throws: ``AsyncTimeoutError/timedOut`` when timeout elapses first.
///
/// ## Example
/// ```swift
/// let avatar = try await withTimeout(.seconds(2), clock: .suspending) {
///   try await imageService.downloadAvatar()
/// }
/// ```
public func withTimeout<R, C: Clock>(
  _ timeout: C.Duration,
  clock: C,
  operation: @escaping @Sendable () async throws -> R
) async throws -> R where C.Duration == Duration {
  try await withThrowingTaskGroup(of: R.self) { group in
    group.addTask {
      try await operation()
    }

    group.addTask {
      try await Task.sleep(until: clock.now.advanced(by: timeout), clock: clock)
      throw AsyncTimeoutError.timedOut
    }

    guard let firstResult = try await group.next() else {
      throw AsyncTimeoutError.timedOut
    }

    group.cancelAll()
    return firstResult
  }
}

/// Runs an async operation with timeout using `SuspendingClock`.
///
/// ## Example
/// ```swift
/// let value = try await withTimeout(.milliseconds(500)) {
///   try await expensiveComputation()
/// }
/// ```
public func withTimeout<R>(
  _ timeout: Duration,
  operation: @escaping @Sendable () async throws -> R
) async throws -> R {
  try await withTimeout(timeout, clock: .suspending, operation: operation)
}

/// Runs multiple operations concurrently and returns the first completed result.
///
/// Remaining operations are cancelled as soon as the first one completes.
///
/// ## Example
/// ```swift
/// let value = try await race(
///   { try await cacheClient.fetch() },
///   { try await networkClient.fetch() }
/// )
/// ```
public func race<R>(
  _ operations: (@Sendable () async throws -> R)...
) async throws -> R {
  try await race(operations)
}

/// Runs multiple operations concurrently and returns the first completed result.
///
/// Remaining operations are cancelled as soon as the first one completes.
public func race<R>(
  _ operations: [@Sendable () async throws -> R]
) async throws -> R {
  precondition(!operations.isEmpty, "At least one operation is required.")

  return try await withThrowingTaskGroup(of: R.self) { group in
    for operation in operations {
      group.addTask {
        try await operation()
      }
    }

    guard let first = try await group.next() else {
      throw AsyncTimeoutError.timedOut
    }
    group.cancelAll()
    return first
  }
}

/// Wrapper around an `AsyncStream` and its continuation.
///
/// You can use this type when you need both pieces to bridge callback-style APIs.
public struct AsyncStreamPipe<Element>: Sendable where Element: Sendable {
  public let stream: AsyncStream<Element>
  public let continuation: AsyncStream<Element>.Continuation

  public init(stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation) {
    self.stream = stream
    self.continuation = continuation
  }
}

/// Wrapper around an `AsyncThrowingStream` and its continuation.
///
/// This type is useful when bridging callback-based APIs that may fail.
public struct AsyncThrowingStreamPipe<Element>: Sendable where Element: Sendable {
  public let stream: AsyncThrowingStream<Element, Error>
  public let continuation: AsyncThrowingStream<Element, Error>.Continuation

  public init(
    stream: AsyncThrowingStream<Element, Error>,
    continuation: AsyncThrowingStream<Element, Error>.Continuation
  ) {
    self.stream = stream
    self.continuation = continuation
  }
}

/// Creates a stream and continuation pair for callback-based event sources.
///
/// ## Example
/// ```swift
/// let pipe = makeAsyncStream() as AsyncStreamPipe<Int>
///
/// someEmitter.onValue = { value in
///   pipe.continuation.yield(value)
/// }
///
/// Task {
///   for await value in pipe.stream {
///     print("Received value:", value)
///   }
/// }
/// ```
public func makeAsyncStream<Element: Sendable>(
  bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
) -> AsyncStreamPipe<Element> {
  let state = NSLockValueBox<AsyncStream<Element>.Continuation?>(wrappedValue: nil)
  let stream = AsyncStream<Element>(bufferingPolicy: bufferingPolicy) { continuation in
    state.withLock { $0 = continuation }
  }

  return .init(stream: stream, continuation: state.withLock { $0! })
}

/// Creates a throwing stream and continuation pair for callback-based event sources.
///
/// ## Example
/// ```swift
/// let pipe = makeAsyncThrowingStream() as AsyncThrowingStreamPipe<Data>
///
/// socketClient.onData = { data in
///   pipe.continuation.yield(data)
/// }
///
/// socketClient.onError = { error in
///   pipe.continuation.finish(throwing: error)
/// }
/// ```
public func makeAsyncThrowingStream<Element: Sendable>(
  bufferingPolicy: AsyncThrowingStream<Element, Error>.Continuation.BufferingPolicy = .unbounded
) -> AsyncThrowingStreamPipe<Element> {
  let state = NSLockValueBox<AsyncThrowingStream<Element, Error>.Continuation?>(wrappedValue: nil)
  let stream = AsyncThrowingStream<Element, Error>(bufferingPolicy: bufferingPolicy) { continuation in
    state.withLock { $0 = continuation }
  }

  return .init(stream: stream, continuation: state.withLock { $0! })
}

private final class NSLockValueBox<Value>: @unchecked Sendable {
  private let lock = NSLock()
  private var value: Value

  init(wrappedValue: Value) {
    self.value = wrappedValue
  }

  func withLock<R>(_ operation: (inout Value) throws -> R) rethrows -> R {
    lock.lock()
    defer { lock.unlock() }
    return try operation(&value)
  }
}

private func randomDuration(upTo maxDuration: Duration) -> Duration {
  guard let maxNanos = durationToNanoseconds(maxDuration), maxNanos > 0 else {
    return .zero
  }

  let randomNanos = Int64.random(in: 0 ... maxNanos)
  return .nanoseconds(randomNanos)
}

private func durationToNanoseconds(_ duration: Duration) -> Int64? {
  let (seconds, attoseconds) = duration.components
  let attosecondsPerNanosecond: Int64 = 1_000_000_000
  let (secondsInNanos, secondsOverflow) = seconds.multipliedReportingOverflow(by: 1_000_000_000)
  if secondsOverflow {
    return nil
  }

  let attosecondsInNanos = attoseconds / attosecondsPerNanosecond
  let (totalNanos, nanosOverflow) = secondsInNanos.addingReportingOverflow(attosecondsInNanos)
  if nanosOverflow {
    return nil
  }
  return totalNanos
}
