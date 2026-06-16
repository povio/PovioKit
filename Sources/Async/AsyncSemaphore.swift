//
//  AsyncSemaphore.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// A lightweight semaphore for limiting concurrent async work.
///
/// Cooperative cancellation is honored: a task suspended in
/// ``waitUnlessCancelled()`` is removed from the waiter queue and resumed
/// promptly with `CancellationError` when its parent task is cancelled.
///
/// ## Example
/// ```swift
/// let semaphore = AsyncSemaphore(value: 3)
///
/// try await withThrowingTaskGroup(of: Void.self) { group in
///   for task in tasks {
///     group.addTask {
///       try await semaphore.withPermit {
///         try await task.run()
///       }
///     }
///   }
///   try await group.waitForAll()
/// }
/// ```
public final class AsyncSemaphore: @unchecked Sendable {
  /// Identifies a single waiter so it can be located inside the queue
  /// when the surrounding `Task` is cancelled.
  private typealias WaiterID = UInt64

  private struct Waiter {
    let id: WaiterID
    /// `nil` once the continuation has already been resumed (either with
    /// a permit by `release()`, or with cancellation by the cancellation
    /// handler). Setting to `nil` and capturing the previous value under
    /// `lock` is what gives us the "resume exactly once" guarantee that
    /// `withCheckedThrowingContinuation` requires.
    var continuation: CheckedContinuation<Void, Error>?
  }

  private struct LegacyWaiter {
    let id: WaiterID
    var continuation: CheckedContinuation<Void, Never>?
  }

  private let lock = NSLock()
  private var permits: Int
  private var waiters: [Waiter] = []
  /// Separate queue for the deprecated, non-cancellable ``acquire()``
  /// entry point. Drained only after every cancellable waiter has been
  /// served, so adopting ``waitUnlessCancelled()`` never starves legacy
  /// callers but does take precedence on a tie.
  private var legacyWaiters: [LegacyWaiter] = []
  private var nextWaiterID: WaiterID = 0

  public init(value: Int) {
    self.permits = max(0, value)
  }

  /// Number of tasks currently suspended waiting for a permit.
  ///
  /// Internal test-only introspection — lets tests synchronise on a waiter
  /// actually entering the queue instead of guessing with a fixed delay.
  var waiterCount: Int {
    lock.withLock { waiters.count + legacyWaiters.count }
  }

  /// Acquires a permit, suspending until one is available.
  ///
  /// If the surrounding task is cancelled while suspended, the call
  /// resumes immediately with `CancellationError` and the waiter slot
  /// is released without consuming a permit.
  ///
  /// > Important: Pair every successful `waitUnlessCancelled()` with
  /// > exactly one ``release()`` (or use ``withPermit(_:)``).
  public func waitUnlessCancelled() async throws {
    try Task.checkCancellation()

    let id: WaiterID = lock.withLock {
      nextWaiterID &+= 1
      return nextWaiterID
    }

    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        let resumeImmediately: Bool = lock.withLock {
          if permits > 0 {
            permits -= 1
            return true
          }
          waiters.append(Waiter(id: id, continuation: continuation))
          return false
        }
        if resumeImmediately {
          continuation.resume()
        }
      }
    } onCancel: {
      let pending = lock.withLock { () -> CheckedContinuation<Void, Error>? in
        guard let index = waiters.firstIndex(where: { $0.id == id }) else {
          // Either we never entered the queue (permit was available
          // immediately) or `release()` already removed us. Nothing to
          // do here — the body either resumed already or is in flight.
          return nil
        }
        let cont = waiters[index].continuation
        waiters.remove(at: index)
        return cont
      }
      pending?.resume(throwing: CancellationError())
    }
  }

  /// Backwards-compatible non-throwing acquire.
  ///
  /// This method does not propagate task cancellation. A task that is
  /// suspended here at the moment its parent is cancelled will continue
  /// to wait for a permit and only resume once one is granted by a
  /// future ``release()`` — meaning a cancelled task can hang
  /// indefinitely if the queue is never drained. Prefer
  /// ``waitUnlessCancelled()``.
  @available(*, deprecated, renamed: "waitUnlessCancelled", message: "Use `try await waitUnlessCancelled()` to honor cooperative task cancellation. The non-throwing variant ignores cancellation and can hang indefinitely.")
  public func acquire() async {
    let id: WaiterID = lock.withLock {
      nextWaiterID &+= 1
      return nextWaiterID
    }

    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
      let resumeImmediately: Bool = lock.withLock {
        if permits > 0 {
          permits -= 1
          return true
        }
        legacyWaiters.append(LegacyWaiter(id: id, continuation: continuation))
        return false
      }
      if resumeImmediately {
        continuation.resume()
      }
    }
  }

  /// Releases one permit. If a task is currently suspended waiting,
  /// it is resumed; otherwise the permit count is incremented for the
  /// next acquirer.
  public func release() {
    let resume = lock.withLock { () -> (() -> Void)? in
      while let next = waiters.first {
        waiters.removeFirst()
        if let continuation = next.continuation {
          return { continuation.resume() }
        }
        // Already resumed via cancellation — keep looking for a live
        // waiter so the released permit isn't lost.
      }
      if let next = legacyWaiters.first, let continuation = next.continuation {
        legacyWaiters.removeFirst()
        return { continuation.resume() }
      } else if !legacyWaiters.isEmpty {
        legacyWaiters.removeFirst()
      }
      permits += 1
      return nil
    }

    resume?()
  }

  /// Acquires a permit, runs `operation`, and releases the permit when
  /// `operation` returns or throws (or the surrounding task is
  /// cancelled before a permit is granted).
  public func withPermit<R>(
    _ operation: @escaping @Sendable () async throws -> R
  ) async throws -> R {
    try await waitUnlessCancelled()
    do {
      let value = try await operation()
      release()
      return value
    } catch {
      release()
      throw error
    }
  }
}
