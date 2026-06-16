//
//  DispatchTimer.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/12/2018.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// A NSTimer replacement using GCD.
///
/// `DispatchTimer` is safe to schedule and stop from multiple threads. All
/// mutations to the underlying `DispatchSourceTimer` are guarded by an
/// `NSLock`.
public final class DispatchTimer: @unchecked Sendable {
  private let lock = NSLock()
  private var timer: DispatchSourceTimer?
  
  public init() {}
  deinit { stop() }
}

// MARK: - Public Methods
public extension DispatchTimer {
  /// Creates and schedules a timer (repeating or one time execution) after given time interval.
  ///
  /// Any previously scheduled timer on this instance is cancelled before the new one is started.
  func schedule(
    interval: DispatchTimeInterval,
    repeating: Bool,
    on queue: DispatchQueue,
    _ completion: (@Sendable () -> Void)?
  ) {
    stop()
    let newTimer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    if repeating {
      newTimer.schedule(deadline: .now() + interval, repeating: interval)
    } else {
      newTimer.schedule(deadline: .now() + interval, leeway: interval)
    }
    newTimer.setEventHandler { [weak self] in
      if !repeating {
        self?.stop()
      }
      completion?()
    }
    
    lock.withLock { timer = newTimer }

    newTimer.activate()
  }
  
  /// Creates and returns `DispatchTimer` object and schedules timer (repeating or one time execution) after given time interval.
  static func scheduled(
    interval: DispatchTimeInterval,
    repeating: Bool,
    on queue: DispatchQueue,
    _ completion: (@Sendable (DispatchTimer) -> Void)?
  ) -> DispatchTimer {
    let timer = DispatchTimer()
    timer.schedule(interval: interval, repeating: repeating, on: queue) { [weak timer] in
      guard let timer else { return }
      completion?(timer)
    }
    return timer
  }
  
  /// Stops dispatch scheduler.
  func stop() {
    let current = lock.withLock {
      let current = timer
      timer = nil
      return current
    }
    current?.cancel()
  }
  
  /// Flag to determine when timer is running.
  var isActive: Bool {
    lock.withLock { timer.map { !$0.isCancelled } ?? false }
  }
}
