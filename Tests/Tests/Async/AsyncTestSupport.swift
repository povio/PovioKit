//
//  AsyncTestSupport.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest

/// Cooperatively polls `condition` until it returns `true`, yielding between
/// checks. Fails the test if the real-time `timeout` elapses first.
///
/// This replaces fixed `Task.sleep` delays that were previously used to
/// "give a task a moment" to reach a suspension point — those depend on
/// scheduler timing and can flake under load. Polling an observable
/// condition is deterministic: it returns as soon as the state is reached.
func waitUntil(
  timeout: Duration = .seconds(5),
  _ condition: @Sendable () async -> Bool,
  file: StaticString = #filePath,
  line: UInt = #line
) async {
  let deadline = ContinuousClock.now.advanced(by: timeout)
  while ContinuousClock.now < deadline {
    if await condition() { return }
    await Task.yield()
  }
  XCTFail("waitUntil timed out after \(timeout)", file: file, line: line)
}

/// A latching gate: tasks `await wait()` until `open()` is called, after
/// which all current and future waiters proceed immediately.
///
/// Used to hold an operation in-flight deterministically (so concurrency or
/// coalescing can be observed) without simulating work via a fixed sleep.
actor Latch {
  private var isOpen = false
  private var waiters: [CheckedContinuation<Void, Never>] = []

  func wait() async {
    if isOpen { return }
    await withCheckedContinuation { waiters.append($0) }
  }

  func open() {
    isOpen = true
    let pending = waiters
    waiters = []
    pending.forEach { $0.resume() }
  }
}
