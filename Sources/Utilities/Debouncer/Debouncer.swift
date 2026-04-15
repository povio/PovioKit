//
//  Debouncer.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public final class Debouncer {
  public struct Behavior: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    public static let leading = Behavior(rawValue: 1 << 0)
    public static let trailing = Behavior(rawValue: 1 << 1)
    public static let leadingAndTrailing: Behavior = [.leading, .trailing]
  }
  
  private let queue: DispatchQueue
  private let lock = NSLock()
  private var trailingJob: DispatchWorkItem?
  private var cooldownJob: DispatchWorkItem?
  private var isCooldownActive = false
  private var shouldExecuteTrailing = false
  public var delay: DispatchTimeInterval
  public var behavior: Behavior
  
  public init(
    queue: DispatchQueue = .main,
    delay: DispatchTimeInterval,
    behavior: Behavior = .trailing
  ) {
    self.queue = queue
    self.delay = delay
    self.behavior = behavior
  }
}

public extension Debouncer {
  func execute(work: @escaping () -> Void) {
    var shouldExecuteLeading = false
    var trailingToSchedule: DispatchWorkItem?
    var cooldownToSchedule: DispatchWorkItem?
    
    lock.lock()
    
    if behavior.contains(.leading), !isCooldownActive {
      shouldExecuteLeading = true
      isCooldownActive = true
      shouldExecuteTrailing = false
    }
    
    if behavior.contains(.trailing) {
      if behavior.contains(.leading), !shouldExecuteLeading {
        shouldExecuteTrailing = true
      } else if !behavior.contains(.leading) {
        shouldExecuteTrailing = true
        isCooldownActive = true
      }
      
      trailingJob?.cancel()
      let trailingJob = DispatchWorkItem { [weak self] in
        guard let self else { return }
        
        var shouldExecute = false
        self.lock.lock()
        if self.behavior.contains(.leading) {
          shouldExecute = self.shouldExecuteTrailing
        } else {
          shouldExecute = true
        }
        self.shouldExecuteTrailing = false
        self.lock.unlock()
        
        guard shouldExecute else { return }
        work()
      }
      self.trailingJob = trailingJob
      trailingToSchedule = trailingJob
    }
    
    if behavior.contains(.leading) || behavior.contains(.trailing) {
      cooldownJob?.cancel()
      let cooldownJob = DispatchWorkItem { [weak self] in
        self?.resetStateAfterCooldown()
      }
      self.cooldownJob = cooldownJob
      cooldownToSchedule = cooldownJob
    }
    
    lock.unlock()
    
    if let trailingToSchedule {
      queue.asyncAfter(deadline: .now() + delay, execute: trailingToSchedule)
    }
    if let cooldownToSchedule {
      queue.asyncAfter(deadline: .now() + delay, execute: cooldownToSchedule)
    }
    if shouldExecuteLeading {
      work()
    }
  }
  
  func executeWithResult<T>(
    work: @escaping () -> T,
    completion: @escaping (T) -> Void
  ) {
    execute {
      completion(work())
    }
  }
  
  func cancelPendingJob() {
    lock.lock()
    trailingJob?.cancel()
    cooldownJob?.cancel()
    trailingJob = nil
    cooldownJob = nil
    isCooldownActive = false
    shouldExecuteTrailing = false
    lock.unlock()
  }
}

private extension Debouncer {
  func resetStateAfterCooldown() {
    lock.lock()
    trailingJob = nil
    cooldownJob = nil
    isCooldownActive = false
    shouldExecuteTrailing = false
    lock.unlock()
  }
}
