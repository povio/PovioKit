//
//  Comparable+PovioKit.swift
//  PovioKit
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension Comparable {
  /// Returns a value clamped to the given inclusive range.
  ///
  /// ```swift
  /// 12.clamped(to: 0...10) // 10
  /// (-3).clamped(to: 0...10) // 0
  /// ```
  func clamped(to limits: ClosedRange<Self>) -> Self {
    min(max(self, limits.lowerBound), limits.upperBound)
  }
}
