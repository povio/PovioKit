//
//  XCConfigValue.swift
//  PovioKit
//
//  Created by Egzon Arifi on 30/03/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore

/// A property wrapper that reads values from the bundle's `Info.plist` (or a
/// custom `BundleReadable` implementation).
///
/// Missing keys or unconvertible values used to terminate the process via
/// `fatalError`; starting with PovioKit 7 they log a descriptive error and
/// return the `defaultValue` supplied via the `= ...` initializer syntax.
///
/// ## Example
/// ```swift
/// @XCConfigValue(key: "API_BASE_URL") static var apiBaseURL: String = "https://example.com"
/// ```
@propertyWrapper
public struct XCConfigValue<Value: LosslessStringConvertible & Sendable>: Sendable {
  private let key: String
  private let defaultValue: Value
  private let bundleReader: BundleReadable
  
  public var wrappedValue: Value {
    value(for: key)
  }
  
  public init(
    wrappedValue defaultValue: Value,
    key: String,
    bundleReader: BundleReadable = BundleReader()
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.bundleReader = bundleReader
  }
}

private extension XCConfigValue {
  func value(for key: String) -> Value {
    guard let object = bundleReader.object(forInfoDictionaryKey: key) else {
      Logger.error("XCConfigValue: missing key `\(key)`. Returning default value.")
      return defaultValue
    }
    
    switch object {
    case let value as Value:
      return value
    case let string as String:
      guard let value = Value(string) else {
        Logger.error("XCConfigValue: value `\(string)` for key `\(key)` is not convertible to \(Value.self). Returning default value.")
        return defaultValue
      }
      return value
    default:
      Logger.error("XCConfigValue: value for key `\(key)` is not of type \(Value.self) or String. Returning default value.")
      return defaultValue
    }
  }
}
