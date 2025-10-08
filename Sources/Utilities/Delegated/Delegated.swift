//
//  Delegated.swift
//  PovioKit
//
//  Created by Toni Kocjan on 20/07/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public struct Delegated<Input, Output> {
  typealias Callback = (Input) -> Output
  private var callback: Callback?
  
  public init() {}
  
  public mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?, Input) -> Output) {
    self.callback = { [weak object] input in
      callback(object, input)
    }
  }
  
  public func callAsFunction(_ arg: Input) -> Output {
    guard let result = callback?(arg) else { fatalError("Implement the delegate method!") }
    return result
  }
}

public extension Delegated where Input == Void {
  mutating func delegate<Object: AnyObject>(to object: Object, with callback: @escaping (Object?) -> Output) {
    self.callback = { [weak object] _ in
      callback(object)
    }
  }
  
  func callAsFunction() -> Output {
    guard let result = callback?(()) else { fatalError("Implement the delegate method!") }
    return result
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
