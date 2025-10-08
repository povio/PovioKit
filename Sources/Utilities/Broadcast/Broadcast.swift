//
//  Broadcast.swift
//  PovioKit
//
//  Created by Domagoj Kulundzic on 26/04/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public final class Broadcast<T> {
  private(set) var observers = [Weak]()

  public init() {}
  
  public func add(observer: T) {
    prune()
    observers.append(Weak(observer as AnyObject))
  }
  
  public func remove(observer: T) {
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
    observers.reversed().forEach {
      guard let delegate = $0.reference as? T else { return }
      invocation(delegate)
    }
  }
  
  public func invoke(
    on queue: DispatchQueue = .main,
    invocation: @escaping (T) -> Void
  ) {
    queue.async {
      self.invoke(invocation: invocation)
    }
  }
  
  public func clear() {
    observers.removeAll()
  }
}

extension Broadcast {
  class Weak {
    weak var reference: AnyObject?
    
    init(_ object: AnyObject) { 
      self.reference = object 
    }
  }
}

private extension Broadcast {
  func prune() {
    observers.removeAll { $0.reference == nil }
  }
}
