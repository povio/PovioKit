//
//  Money+Defaults.swift
//  PovioKit
//
//  Created by Toni K. Turk on 19/04/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

private let moneyDefaultsLock = NSLock()
// Access to this global is serialised by `moneyDefaultsLock`, so it is safe
// to share across threads despite being a mutable global.
nonisolated(unsafe) private var moneyDefaultsStorage = Money.Defaults()

public extension Money {
  struct Defaults: Sendable {
    public var precision = 2
    public var currency = Currency.usd
    public var locale = Locale.current
    
    public init() {}
  }
  
  static var defaults: Defaults {
    get {
      moneyDefaultsLock.lock()
      defer { moneyDefaultsLock.unlock() }
      return moneyDefaultsStorage
    }
    _modify {
      moneyDefaultsLock.lock()
      defer { moneyDefaultsLock.unlock() }
      yield &moneyDefaultsStorage
    }
    set {
      moneyDefaultsLock.lock()
      defer { moneyDefaultsLock.unlock() }
      moneyDefaultsStorage = newValue
    }
  }
}

/// Legacy global alias kept for backwards compatibility.
///
/// Prefer `Money.defaults` for clarity.
public var defaults: Money.Defaults {
  get { Money.defaults }
  set { Money.defaults = newValue }
}
