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
  private var tasks: [Key: Task<Value, Error>] = [:]

  public init() {}

  public func value(
    for key: Key,
    operation: @escaping @Sendable () async throws -> Value
  ) async throws -> Value {
    if let existingTask = tasks[key] {
      return try await existingTask.value
    }

    let task = Task {
      try await operation()
    }
    tasks[key] = task

    do {
      let value = try await task.value
      tasks[key] = nil
      return value
    } catch {
      tasks[key] = nil
      throw error
    }
  }

  public func cancelValue(for key: Key) {
    tasks[key]?.cancel()
    tasks[key] = nil
  }

  public func cancelAll() {
    let pendingTasks = tasks.values
    tasks.removeAll()
    pendingTasks.forEach { $0.cancel() }
  }
}
