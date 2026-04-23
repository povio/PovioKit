//
//  AsyncSampleSequence.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// `AsyncSampleSequence` emits values from a base sequence no more often
/// than once per `delayBetweenElements`. When several values arrive inside
/// the same window, earlier values are dropped and only the newest is
/// emitted once the window closes.
///
/// This is distinct from ``AsyncDebounceSequence``: this sequence is
/// *source-driven* — it keeps pulling from the base and collapses bursts to
/// the latest element. ``AsyncDebounceSequence`` is *caller-driven* and
/// cancels in-flight fetches on each new `next()` call.
public struct AsyncSampleSequence<BaseSequence: AsyncSequence, C: Clock> {
  let baseSequence: BaseSequence
  let clock: C
  let delayBetweenElements: C.Duration

  public init(
    _ baseSequence: BaseSequence,
    clock: C,
    delayBetweenElements: C.Duration
  ) {
    self.baseSequence = baseSequence
    self.clock = clock
    self.delayBetweenElements = delayBetweenElements
  }
}

extension AsyncSampleSequence: AsyncSequence where C.Duration == Duration {
  public typealias Element = BaseSequence.Element

  public final class Iterator: AsyncIteratorProtocol {
    typealias PendingValue = (value: Element, timestamp: C.Instant)

    var baseIterator: BaseSequence.AsyncIterator
    let clock: C
    let delayBetweenElements: Duration
    var hasEnded = false
    var pending: PendingValue?

    init(
      baseIterator: BaseSequence.AsyncIterator,
      clock: C,
      delayBetweenElements: Duration
    ) {
      self.baseIterator = baseIterator
      self.clock = clock
      self.delayBetweenElements = delayBetweenElements
    }

    public func next() async throws -> Element? {
      if hasEnded {
        return nil
      }

      var latest: Element
      var latestTimestamp: C.Instant

      if let pending {
        latest = pending.value
        latestTimestamp = pending.timestamp
        self.pending = nil
      } else {
        guard let first = try await baseIterator.next() else {
          hasEnded = true
          return nil
        }
        latest = first
        latestTimestamp = clock.now
      }

      while true {
        guard let nextValue = try await baseIterator.next() else {
          // End of source: wait out the window before emitting latest.
          let emitAt = latestTimestamp.advanced(by: delayBetweenElements)
          if emitAt > clock.now {
            try await Task.sleep(until: emitAt, clock: clock)
          }
          hasEnded = true
          return latest
        }

        let now = clock.now
        if latestTimestamp.duration(to: now) >= delayBetweenElements {
          pending = (nextValue, now)
          return latest
        }

        latest = nextValue
        latestTimestamp = now
      }
    }
  }

  public func makeAsyncIterator() -> Iterator {
    .init(
      baseIterator: baseSequence.makeAsyncIterator(),
      clock: clock,
      delayBetweenElements: delayBetweenElements
    )
  }
}

public extension AsyncSequence {
  /// Creates a sampling wrapper around this sequence.
  ///
  /// ## Example
  /// ```swift
  /// let sampled = sensorReadings.sample(
  ///   clock: .suspending,
  ///   delayBetweenElements: .milliseconds(500)
  /// )
  /// ```
  func sample<C: Clock>(
    clock: C,
    delayBetweenElements: C.Duration
  ) -> AsyncSampleSequence<Self, C> {
    .init(self, clock: clock, delayBetweenElements: delayBetweenElements)
  }
}
