//
//  Double+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/09/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension Double {
  /// Converts a value from one unit of measurement to another.
  ///
  /// This method uses the `Measurement` API to perform the conversion between two dimensional units.
  /// It creates a `Measurement` from the current `Double` value using the `from` unit, then converts
  /// it to the desired `to` unit and returns the result.
  ///
  /// - Parameters:
  ///   - from: The unit of measurement for the current value (e.g., meters, kilograms).
  ///   - to: The unit of measurement to convert the current value into (e.g., feet, pounds).
  /// - Returns: The converted value as a `Double` in the `to` unit of measurement.
  func convert(from: Dimension, to: Dimension) -> Double {
    Measurement(value: self, unit: from)
      .converted(to: to)
      .value
  }
}
