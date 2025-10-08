//
//  DispatchTimeInterval+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension DispatchTimeInterval {
  /// Returns `TimeInterval`.
  /// Useful when there is a need to convert from `DispatchTimeInterval`.
  ///
  /// ## Example
  /// ```swift
  /// let duration: DispatchTimeInterval = .seconds(1)
  /// UIView.animate(withDuration: duration.timeInterval, delay: 0) {}
  /// ```
  var timeInterval: TimeInterval {
    switch self {
    case .seconds(let value):
      return TimeInterval(value)
    case .milliseconds(let value):
      return TimeInterval(value) / 1_000
    case .microseconds(let value):
      return TimeInterval(value) / 1_000_000
    case .nanoseconds(let value):
      return TimeInterval(value) / 1_000_000_000
    case .never:
      return TimeInterval(Double.infinity)
    @unknown default:
      return TimeInterval(0)
    }
  }
}
