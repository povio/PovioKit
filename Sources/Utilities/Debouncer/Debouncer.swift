//
//  Debouncer.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// Rate-limits the execution of closures submitted through ``execute(_:)``
/// using the classic debounce semantics (`.leading`, `.trailing`, or both).
///
/// This is the closure-style counterpart to
/// ``AsyncSequence/debounce(clock:delayBetweenTasks:)``; use the sequence
/// when you already have an `AsyncSequence` of values and want to debounce
/// the elements, and use `Debouncer` when you want to debounce discrete
/// user events such as keystrokes or button taps.
///
/// ## Behaviors
///
/// - ``Behavior/trailing``: Fires the most recently submitted closure after
///   `delay` has elapsed without any further activity. This is the default
///   and matches the classic "debounce" semantics from Underscore / Lodash
///   / RxSwift.
/// - ``Behavior/leading``: Fires the first closure in a quiescent window
///   immediately and drops every further call until the cooldown elapses.
/// - ``Behavior/leadingAndTrailing``: Fires on the leading edge *and* once
///   more on the trailing edge of a burst (last-value-wins for the
///   trailing call).
///
/// ## Concurrency
///
/// `Debouncer` is `Sendable` and can be called from any isolation domain.
/// Internally it schedules cooldowns via `Task.sleep(for:)`, so pending
/// work is cancelled through the standard cooperative-cancellation path.
///
/// Submitted closures must be `@Sendable` because they may execute on a
/// detached task. If you need main-actor isolation, wrap your work
/// explicitly:
///
/// ```swift
/// debouncer.execute {
///   Task { @MainActor in await updateUI() }
/// }
/// ```
///
/// ## Example
///
/// ```swift
/// final class SearchWorker {
///   private let debouncer = Debouncer(delay: .milliseconds(350))
///
///   func search(query: String) {
///     debouncer.execute {
///       Task { await self.performSearch(query: query) }
///     }
///   }
/// }
/// ```
public final class Debouncer: @unchecked Sendable {
  public struct Behavior: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let leading = Behavior(rawValue: 1 << 0)
    public static let trailing = Behavior(rawValue: 1 << 1)
    public static let leadingAndTrailing: Behavior = [.leading, .trailing]
  }

  public var delay: Duration {
    get { lock.withLock { _delay } }
    set { lock.withLock { _delay = newValue } }
  }

  public var behavior: Behavior {
    get { lock.withLock { _behavior } }
    set { lock.withLock { _behavior = newValue } }
  }

  private let lock = NSLock()
  private var _delay: Duration
  private var _behavior: Behavior
  private var cooldownTask: Task<Void, Never>?
  private var pendingWork: (@Sendable () -> Void)?

  /// A monotonically increasing identifier for the currently-active
  /// cooldown window. We compare against this in `finishCooldown` so that
  /// a timer which fires after the state has already moved on (because a
  /// later `execute` restarted the window, or `cancel()` was called) is
  /// ignored instead of running stale `pendingWork`.
  private var generation: UInt64 = 0

  public init(delay: Duration, behavior: Behavior = .trailing) {
    self._delay = delay
    self._behavior = behavior
  }

  /// Submits `work` to the debouncer. Whether the closure executes
  /// immediately, after `delay`, or not at all depends on the active
  /// ``behavior`` and on whether the debouncer is currently in a cooldown
  /// window.
  public func execute(_ work: @Sendable @escaping () -> Void) {
    var leadingWork: (@Sendable () -> Void)?

    lock.lock()
    let behavior = _behavior
    let delay = _delay
    let hasCooldown = cooldownTask != nil

    if behavior.contains(.leading), !hasCooldown {
      // First call in a quiescent window — fire the leading edge and
      // clear any stale trailing work.
      leadingWork = work
      pendingWork = nil
    } else if behavior.contains(.trailing) {
      // Remember this as the latest candidate for the trailing edge.
      pendingWork = work
    }

    // Decide whether the timer needs to be (re)started.
    let shouldRestart: Bool
    if behavior == .trailing && hasCooldown {
      // Pure trailing debounce: every call resets the cooldown, so the
      // closure only fires after `delay` of silence.
      cooldownTask?.cancel()
      shouldRestart = true
    } else {
      // Leading-only, leading+trailing, and the first trailing call all
      // start the cooldown once; subsequent calls within the window ride
      // the existing timer.
      shouldRestart = !hasCooldown
    }

    if shouldRestart {
      generation &+= 1
      let gen = generation
      cooldownTask = Task { [weak self] in
        do {
          try await Task.sleep(for: delay)
        } catch {
          return
        }
        self?.finishCooldown(for: gen)
      }
    }
    lock.unlock()

    // Run the leading closure outside the lock so that the user code can
    // re-enter the debouncer without deadlocking.
    leadingWork?()
  }

  /// Convenience wrapper that computes a value on the leading / trailing
  /// edge and forwards it to `completion`.
  public func executeWithResult<T: Sendable>(
    work: @Sendable @escaping () -> T,
    completion: @Sendable @escaping (T) -> Void
  ) {
    execute { completion(work()) }
  }

  /// Discards any pending trailing work and resets the cooldown state.
  public func cancel() {
    lock.lock()
    cooldownTask?.cancel()
    cooldownTask = nil
    pendingWork = nil
    generation &+= 1
    lock.unlock()
  }

  @available(*, deprecated, renamed: "cancel")
  public func cancelPendingJob() { cancel() }

  private func finishCooldown(for gen: UInt64) {
    var work: (@Sendable () -> Void)?
    lock.lock()
    if gen == generation {
      // This timer is still the authoritative one — publish its trailing
      // work and mark the debouncer as quiescent.
      work = pendingWork
      pendingWork = nil
      cooldownTask = nil
    }
    lock.unlock()
    work?()
  }
}
