//
//  Throttler.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 1/05/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public class Throttler {
  private let queue: DispatchQueue
  private let lock = NSLock()
  private var job: DispatchWorkItem?
  public var delay: DispatchTimeInterval
  
  public init(queue: DispatchQueue = .main, delay: DispatchTimeInterval) {
    self.queue = queue
    self.delay = delay
  }
}

public extension Throttler {
  func execute(work: @escaping () -> Void) {
    let newJob = DispatchWorkItem(block: work)
    replacePendingJob(with: newJob)?.cancel()
    queue.asyncAfter(deadline: .now() + delay, execute: newJob)
  }
  
  func executeWithResult<T>(
    work: @escaping () -> T,
    completion: @escaping (T) -> Void
  ) {
    let newJob = DispatchWorkItem {
      completion(work())
    }
    replacePendingJob(with: newJob)?.cancel()
    queue.asyncAfter(deadline: .now() + delay, execute: newJob)
  }
  
  func cancelPendingJob() {
    replacePendingJob(with: nil)?.cancel()
  }
}

private extension Throttler {
  @discardableResult
  func replacePendingJob(with newValue: DispatchWorkItem?) -> DispatchWorkItem? {
    lock.lock()
    defer { lock.unlock() }
    let oldValue = job
    job = newValue
    return oldValue
  }
}
