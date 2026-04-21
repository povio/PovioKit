//
//  Delegated.swift
//  PovioKit
//
//  Created by Toni Kocjan on 20/07/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// A lightweight weak-delegate helper that invokes a closure on the captured
/// object, returning `Output?` (nil when no delegate was attached).
///
/// Specializations for `Output == Void` return `Void` directly; in that case
/// the absence of a delegate is silently ignored — the typical
/// "fire-and-forget" UI callback pattern.
public struct Delegated<Input, Output> {
  typealias Callback = (Input) -> Output
  private var callback: Callback?
  
  public init() {}
  
  public mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?, Input) -> Output) {
    self.callback = { [weak object] input in
      callback(object, input)
    }
  }
  
  /// Invokes the delegate and returns its `Output`, or `nil` if no delegate
  /// has been attached yet.
  public func callAsFunction(_ arg: Input) -> Output? {
    callback?(arg)
  }
}

public extension Delegated where Input == Void {
  mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?) -> Output) {
    self.callback = { [weak object] _ in
      callback(object)
    }
  }
  
  /// Invokes the delegate and returns its `Output`, or `nil` if no delegate
  /// has been attached yet.
  func callAsFunction() -> Output? {
    callback?(())
  }
}

public extension Delegated where Output == Void {
  func callAsFunction(_ arg: Input) {
    callback?(arg)
  }
}

public extension Delegated where Input == Void, Output == Void {
  mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?) -> Void) {
    self.callback = { [weak object] _ in
      callback(object)
    }
  }
  
  func callAsFunction() {
    callback?(())
  }
}

public typealias VoidDelegate = Delegated<Void, Void>
