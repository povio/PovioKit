//
//  AsyncTickerSequence.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// An infinite sequence that emits timestamps at a fixed interval.
///
/// ## Example
/// ```swift
/// let ticker = AsyncTickerSequence(
///   clock: ContinuousClock(),
///   interval: .seconds(1)
/// )
///
/// var iterator = ticker.makeAsyncIterator()
/// let firstTick = try await iterator.next()
/// ```
public struct AsyncTickerSequence<C: Clock> where C.Duration == Duration {
  let clock: C
  let interval: Duration
  let initialDelay: Duration

  public init(
    clock: C,
    interval: Duration,
    initialDelay: Duration = .zero
  ) {
    self.clock = clock
    self.interval = Swift.max(.zero, interval)
    self.initialDelay = Swift.max(.zero, initialDelay)
  }
}

extension AsyncTickerSequence: AsyncSequence {
  public typealias Element = C.Instant

  public struct Iterator: AsyncIteratorProtocol {
    let clock: C
    let interval: Duration
    var nextTick: C.Instant

    init(clock: C, interval: Duration, initialDelay: Duration) {
      self.clock = clock
      self.interval = interval
      self.nextTick = clock.now.advanced(by: initialDelay)
    }

    public mutating func next() async throws -> C.Instant? {
      try await Task.sleep(until: nextTick, clock: clock)
      let emittedTick = nextTick
      nextTick = emittedTick.advanced(by: interval)
      return emittedTick
    }
  }

  public func makeAsyncIterator() -> Iterator {
    .init(
      clock: clock,
      interval: interval,
      initialDelay: initialDelay
    )
  }
}
