//
//  Double+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/09/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension Double {
  /// Converts a value from one unit of measurement to another.
  ///
  /// This method uses the `Measurement` API to perform the conversion between
  /// two dimensional units. Because `Measurement.converted(to:)` terminates
  /// the process when the two dimensions are incompatible (for example
  /// converting meters to pounds), this wrapper guards against such misuse
  /// and returns `.nan` instead.
  ///
  /// Callers that want to detect incompatible dimensions should inspect
  /// `result.isNaN` (or `result.isFinite`) before using the value.
  ///
  /// - Parameters:
  ///   - from: The unit of measurement for the current value (e.g., meters, kilograms).
  ///   - to: The unit of measurement to convert the current value into (e.g., feet, pounds).
  /// - Returns: The converted value as a `Double` in the `to` unit of
  ///            measurement, or `.nan` if `from` and `to` belong to different
  ///            dimension types (e.g. length vs. mass).
  func convert(from: Dimension, to: Dimension) -> Double {
    guard type(of: from) == type(of: to) else { return .nan }
    return Measurement(value: self, unit: from)
      .converted(to: to)
      .value
  }
}
