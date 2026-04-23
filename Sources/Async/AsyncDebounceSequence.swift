//
//  AsyncDebounceSequence.swift
//  PovioKit
//
//  Created by Toni K. Turk on 22/08/2023.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// `AsyncDebounceSequence` is a wrapper around an `AsyncSequence` that introduces
/// a quiet-period between successive pulls. Every time ``Iterator/next()`` is
/// called, any previously scheduled fetch is cancelled; only the latest
/// request survives long enough to fetch from the base sequence.
///
/// This is the typical shape of a text-field / search debouncer where you do
/// not want to perform expensive work for every keystroke, but only once the
/// user has paused typing.
///
/// ## Example
///
/// ```swift
/// struct SearchAsyncSequence: AsyncSequence {
///   typealias Element = [Item]
///
///   func makeAsyncIterator() -> PostsAsyncIterator {
///     PostsAsyncIterator()
///   }
/// }
///
/// struct PostsAsyncIterator: AsyncIteratorProtocol {
///   typealias Element = [Item]
///
///   func next() async throws -> Element? {
///     try await callSearchAPI(...)
///   }
/// }
///
/// class ViewModel: ObservableObject {
///   private var debouncedSearch = SearchAsyncSequence()
///     .debounce(clock: .suspending, delayBetweenTasks: .milliseconds(600))
///     .makeAsyncIterator()
///
///   @MainActor
///   func search() {
///     Task {
///       guard let results = try await debouncedSearch.next() else { return }
///       // ...
///     }
///   }
/// }
/// ```
///
/// - Parameters:
///   - BaseSequence: The type of the underlying `AsyncSequence`.
///   - C: The type of the `Clock` used to measure the quiet-period.
public struct AsyncDebounceSequence<BaseSequence: AsyncSequence & Sendable, C: Clock>: Sendable where
  BaseSequence.Element: Sendable,
  BaseSequence.AsyncIterator: Sendable
{
  let baseSequence: BaseSequence
  let clock: C
  let delayBetweenTasks: C.Duration

  /// Initializes a new `AsyncDebounceSequence` instance.
  ///
  /// - Parameters:
  ///   - baseSequence: The underlying `AsyncSequence`.
  ///   - clock: The `Clock` used to measure the quiet-period.
  ///   - delayBetweenTasks: The duration of the quiet-period between tasks.
  public init(
    _ baseSequence: BaseSequence,
    clock: C,
    delayBetweenTasks: C.Duration
  ) {
    self.baseSequence = baseSequence
    self.clock = clock
    self.delayBetweenTasks = delayBetweenTasks
  }
}

extension AsyncDebounceSequence: AsyncSequence where C.Duration == Duration {
  public typealias Element = BaseSequence.Element

  public final class Iterator: AsyncIteratorProtocol, @unchecked Sendable {
    // Access to `baseIterator` and `taskInExecution` is serialised by the
    // debouncer's own cancel-and-replace protocol in `next()` plus the internal
    // `lock`, so the class is safe to mark `@unchecked Sendable`.
    var baseIterator: BaseSequence.AsyncIterator
    var taskInExecution: Task<Element?, Error>?
    let clock: C
    let delayBetweenTasks: C.Duration
    let lock = NSLock()

    init(
      baseIterator: BaseSequence.AsyncIterator,
      clock: C,
      delayBetweenTasks: C.Duration
    ) {
      self.baseIterator = baseIterator
      self.clock = clock
      self.delayBetweenTasks = delayBetweenTasks
    }

    public func next() async throws -> Element? {
      try Task.checkCancellation()
      let task = lock.withLock { () -> Task<Element?, Error> in
        taskInExecution?.cancel()
        taskInExecution = nil
        let task = Task { [weak self, clock, delayBetweenTasks] () -> Element? in
          try await Task.sleep(
            until: clock.now.advanced(by: delayBetweenTasks),
            clock: clock
          )
          guard let self else { return nil }
          let result = try await self.baseIterator.next()
          try Task.checkCancellation()
          return result
        }
        taskInExecution = task
        return task
      }
      return try await withTaskCancellationHandler {
        do {
          return try await task.value
        } catch is CancellationError {
          // Two kinds of cancellation reach this path:
          //   1. A newer call to `next()` cancelled our internal task to
          //      debounce it away — the correct answer is "no element yet".
          //   2. The caller's enclosing Task was cancelled — we must propagate
          //      the `CancellationError` so the caller can unwind.
          // We can tell the two apart by inspecting the current task's
          // cancellation flag here: only (2) flips it.
          if Task.isCancelled {
            throw CancellationError()
          }
          return nil
        } catch {
          throw error
        }
      } onCancel: {
        task.cancel()
      }
    }
  }

  public func makeAsyncIterator() -> Iterator {
    .init(
      baseIterator: baseSequence.makeAsyncIterator(),
      clock: clock,
      delayBetweenTasks: delayBetweenTasks
    )
  }
}

public extension AsyncSequence where
  Self: Sendable,
  Element: Sendable,
  AsyncIterator: Sendable
{
  /// Wraps `self` so each call to `next()` on the resulting iterator cancels
  /// any prior in-flight fetch and only proceeds if no new call arrives
  /// within `delayBetweenTasks`.
  func debounce<C: Clock>(
    clock: C,
    delayBetweenTasks: C.Duration
  ) -> AsyncDebounceSequence<Self, C> {
    .init(self, clock: clock, delayBetweenTasks: delayBetweenTasks)
  }
}
