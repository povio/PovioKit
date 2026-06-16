//
//  TestClock.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// Minimal, deterministic `Clock` implementation for tests.
///
/// A `TestClock` keeps a virtual current time that only advances when the
/// test explicitly asks it to via ``advance(by:)`` or ``run()``. Any task
/// that calls ``sleep(until:tolerance:)`` is suspended until its deadline
/// is reached on the virtual clock.
///
/// ## Typical Use
///
/// ```swift
/// let clock = TestClock()
/// let ticker = AsyncTickerSequence(clock: clock, interval: .milliseconds(10))
///
/// var iterator = ticker.makeAsyncIterator()
/// async let tick = iterator.next()            // starts sleeping on the clock
/// await clock.waitForSleepers(count: 1)       // ensure the sleep is registered
/// await clock.advance(by: .milliseconds(10))  // move virtual time forward
/// let instant = try await tick                // tick now returns
/// ```
///
/// The clock is intentionally scoped to the Async test target — it is not
/// published as production API because correct concurrency-aware fake clocks
/// are subtle and we prefer to revisit them before making public commitments.
final class TestClock: Clock, @unchecked Sendable {
  struct Instant: InstantProtocol {
    typealias Duration = Swift.Duration
    var offset: Duration

    func advanced(by duration: Duration) -> Self {
      .init(offset: offset + duration)
    }

    func duration(to other: Self) -> Duration {
      other.offset - offset
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.offset < rhs.offset
    }
  }

  typealias Duration = Swift.Duration

  private let lock = NSLock()
  private var currentOffset: Duration = .zero
  private var sleepers: [Sleeper] = []
  private var recordedDelays: [Duration] = []
  private var nextSleeperID: UInt64 = 0

  /// The delay (relative to the virtual clock at the moment of the call)
  /// requested by every `sleep(until:)`, in call order. Lets tests assert
  /// the exact back-off schedule without measuring wall-clock time.
  var requestedSleepDelays: [Duration] { lock.withLock { recordedDelays } }

  private struct Sleeper {
    let id: UInt64
    let deadline: Instant
    let continuation: CheckedContinuation<Void, Error>
  }

  var now: Instant { lock.withLock { Instant(offset: currentOffset) } }
  var minimumResolution: Duration { .zero }

  func sleep(until deadline: Instant, tolerance: Duration? = nil) async throws {
    try Task.checkCancellation()
    let id: UInt64 = lock.withLock {
      nextSleeperID &+= 1
      return nextSleeperID
    }

    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        let resumeImmediately = lock.withLock { () -> Bool in
          recordedDelays.append(deadline.offset - currentOffset)
          if currentOffset >= deadline.offset {
            return true
          }
          sleepers.append(.init(id: id, deadline: deadline, continuation: continuation))
          return false
        }
        if resumeImmediately {
          continuation.resume()
        }
      }
    } onCancel: {
      let pending = lock.withLock { () -> CheckedContinuation<Void, Error>? in
        guard let index = sleepers.firstIndex(where: { $0.id == id }) else { return nil }
        let cont = sleepers[index].continuation
        sleepers.remove(at: index)
        return cont
      }
      pending?.resume(throwing: CancellationError())
    }
  }

  /// Moves the virtual clock forward and resumes every sleeper whose
  /// deadline has been reached.
  func advance(by duration: Duration) async {
    let resumed: [CheckedContinuation<Void, Error>] = lock.withLock {
      currentOffset = currentOffset + duration
      var ready: [CheckedContinuation<Void, Error>] = []
      var remaining: [Sleeper] = []
      for sleeper in sleepers {
        if sleeper.deadline.offset <= currentOffset {
          ready.append(sleeper.continuation)
        } else {
          remaining.append(sleeper)
        }
      }
      sleepers = remaining
      return ready
    }
    for continuation in resumed {
      continuation.resume()
    }
    // Give resumed tasks a chance to run (and potentially register new
    // sleepers) before we return.
    await Task.megaYield()
  }

  /// Blocks (cooperatively) until at least `count` sleepers are registered
  /// on the clock, or the real-time `timeout` elapses.
  ///
  /// This is how tests synchronise with async code that hasn't yet reached
  /// its `sleep(until:)` call site.
  func waitForSleepers(
    count: Int = 1,
    timeout: Swift.Duration = .seconds(1)
  ) async {
    let deadline = ContinuousClock.now.advanced(by: timeout)
    while ContinuousClock.now < deadline {
      if lock.withLock({ sleepers.count >= count }) { return }
      await Task.yield()
    }
  }

  /// Drains all currently registered sleepers by advancing the clock to each
  /// deadline in order.
  func run() async {
    while true {
      let next: Instant? = lock.withLock { sleepers.map(\.deadline).min(by: <) }
      guard let next = next, next.offset > currentOffset else { return }
      await advance(by: currentOffset.distance(to: next.offset))
    }
  }
}

private extension Swift.Duration {
  func distance(to other: Swift.Duration) -> Swift.Duration {
    other - self
  }
}

private extension Task where Success == Never, Failure == Never {
  /// Cooperatively yields multiple times so that downstream continuations
  /// have a realistic chance to execute before the caller proceeds. A single
  /// `Task.yield()` does not always suffice on fast hardware.
  static func megaYield(count: Int = 10) async {
    for _ in 0..<count {
      await Task.yield()
    }
  }
}
