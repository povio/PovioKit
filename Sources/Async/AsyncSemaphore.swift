//
//  AsyncSemaphore.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// A lightweight semaphore for limiting concurrent async work.
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
  private let lock = NSLock()
  private var permits: Int
  private var waiters: [CheckedContinuation<Void, Never>] = []

  public init(value: Int) {
    self.permits = max(0, value)
  }

  public func acquire() async {
    let shouldSuspend = lock.withLock {
      if permits > 0 {
        permits -= 1
        return false
      }
      return true
    }

    if shouldSuspend {
      await withCheckedContinuation { continuation in
        lock.withLock {
          waiters.append(continuation)
        }
      }
    }
  }

  public func release() {
    let waiter = lock.withLock { () -> CheckedContinuation<Void, Never>? in
      if !waiters.isEmpty {
        return waiters.removeFirst()
      }
      permits += 1
      return nil
    }

    waiter?.resume()
  }

  public func withPermit<R>(
    _ operation: @escaping @Sendable () async throws -> R
  ) async rethrows -> R {
    await acquire()
    defer { release() }
    return try await operation()
  }
}

private extension NSLock {
  func withLock<R>(_ operation: () throws -> R) rethrows -> R {
    lock()
    defer { unlock() }
    return try operation()
  }
}
