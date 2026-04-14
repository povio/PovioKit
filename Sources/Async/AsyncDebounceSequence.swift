//
//  AsyncDebounceSequence.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// `AsyncDebounceSequence` emits the latest element only after a quiet period.
///
/// When multiple values arrive within `delayBetweenElements`, earlier values are
/// discarded and only the newest value is emitted.
public struct AsyncDebounceSequence<BaseSequence: AsyncSequence, C: Clock> {
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

extension AsyncDebounceSequence: AsyncSequence where C.Duration == Duration {
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
          // End of source: wait out debounce window before emitting latest.
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
  /// Creates a debounced wrapper around this sequence.
  ///
  /// ## Example
  /// ```swift
  /// let debounced = queryChanges.debounce(
  ///   clock: .suspending,
  ///   delayBetweenElements: .milliseconds(350)
  /// )
  /// ```
  func debounce<C: Clock>(
    clock: C,
    delayBetweenElements: C.Duration
  ) -> AsyncDebounceSequence<Self, C> {
    .init(self, clock: clock, delayBetweenElements: delayBetweenElements)
  }
}
