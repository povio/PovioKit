//
//  TaskCoalescer.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// Deduplicates in-flight async work by key.
///
/// If multiple callers request the same key concurrently, only one operation
/// runs and all callers await the same task result.
///
/// ## Example
/// ```swift
/// let coalescer = TaskCoalescer<String, User>()
///
/// let user = try await coalescer.value(for: "user-42") {
///   try await apiClient.fetchUser(id: "user-42")
/// }
/// ```
public actor TaskCoalescer<Key: Hashable & Sendable, Value: Sendable> {
  private struct Entry {
    let id: UInt64
    let task: Task<Value, Error>
  }

  private var tasks: [Key: Entry] = [:]
  private var nextId: UInt64 = 0
  private var awaiters: Int = 0

  public init() {}

  /// Number of keys with an operation currently in flight.
  ///
  /// Internal test-only introspection — lets tests synchronise on an
  /// operation actually being registered instead of guessing with a delay.
  var inFlightCount: Int { tasks.count }

  /// Number of callers currently awaiting an already in-flight operation
  /// (coalesced joiners, excluding the caller that started the work).
  ///
  /// Internal test-only introspection.
  var awaiterCount: Int { awaiters }

  public func value(
    for key: Key,
    operation: @escaping @Sendable () async throws -> Value
  ) async throws -> Value {
    if let existing = tasks[key] {
      awaiters += 1
      defer { awaiters -= 1 }
      return try await existing.task.value
    }

    nextId &+= 1
    let id = nextId
    let task = Task {
      try await operation()
    }
    tasks[key] = Entry(id: id, task: task)

    defer {
      // Only clear the slot if it still holds the same task; a concurrent
      // cancel + new submission may have put a newer task in place already.
      if tasks[key]?.id == id {
        tasks[key] = nil
      }
    }

    return try await task.value
  }

  public func cancelValue(for key: Key) {
    guard let entry = tasks.removeValue(forKey: key) else { return }
    entry.task.cancel()
  }

  public func cancelAll() {
    let pendingTasks = tasks.values.map(\.task)
    tasks.removeAll()
    pendingTasks.forEach { $0.cancel() }
  }
}
