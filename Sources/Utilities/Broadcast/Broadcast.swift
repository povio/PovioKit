//
//  Broadcast.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// A thread-safe, weakly-held observer list.
///
/// `Broadcast` stores observers using weak references so callers do not need
/// to explicitly remove them to avoid retain cycles.
///
/// > Important: `T` must be a class-bound type (a concrete class, or a
/// > protocol declared with `: AnyObject`). Value types will appear to add
/// > successfully but will be pruned immediately because the underlying
/// > weak reference cannot retain them. This is intentional; Swift does not
/// > allow expressing `T: AnyObject` together with existential protocol
/// > types, so the class-bound requirement is documented rather than
/// > enforced at compile time.
public final class Broadcast<T>: @unchecked Sendable {
  // All mutable state (`observers`) is serialised via `lock`, so the class is
  // safe to share across threads. The observer objects themselves are the
  // user's responsibility; if they are not themselves thread-safe, they
  // should not use `invoke(on:invocation:)` to dispatch to a background queue.
  private let lock = NSLock()
  private var observers = [Weak]()

  public init() {}
  
  public func add(observer: T) {
    lock.lock()
    defer { lock.unlock() }
    prune()
    observers.append(Weak(observer as AnyObject))
  }
  
  public func remove(observer: T) {
    lock.lock()
    defer { lock.unlock() }
    prune()
    let index = observers.firstIndex {
      $0.reference === observer as AnyObject
    }
    guard let index else { return }
    if observers.count == 1 || index == observers.count - 1 {
      observers.removeLast()
    } else {
      observers.swapAt(observers.count - 1, index)
      observers.removeLast()
    }
  }
  
  public func invoke(invocation: (T) -> Void) {
    lock.lock()
    prune()
    let listeners = observers.compactMap { $0.reference as? T }
    lock.unlock()
    
    listeners.reversed().forEach {
      invocation($0)
    }
  }
  
  public func invoke(
    on queue: DispatchQueue = .main,
    invocation: @escaping @Sendable (T) -> Void
  ) {
    queue.async {
      self.invoke(invocation: invocation)
    }
  }
  
  public func clear() {
    lock.lock()
    defer { lock.unlock() }
    observers.removeAll()
  }
  
  /// The current number of live observers.
  ///
  /// Stale weak references are pruned before counting. Intended for
  /// diagnostic / debugging purposes; do not rely on this value for control
  /// flow.
  public var observerCount: Int {
    lock.lock()
    defer { lock.unlock() }
    prune()
    return observers.count
  }
}

private extension Broadcast {
  final class Weak {
    weak var reference: AnyObject?
    
    init(_ object: AnyObject) { 
      self.reference = object 
    }
  }
  
  func prune() {
    observers.removeAll { $0.reference == nil }
  }
}
