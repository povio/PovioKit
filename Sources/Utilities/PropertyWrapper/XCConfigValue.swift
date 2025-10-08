//
//  XCConfigValue.swift
//  PovioKit
//
//  Created by Egzon Arifi on 30/03/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct XCConfigValue<Value: LosslessStringConvertible> {
  private let key: String
  private let bundleReader: BundleReadable
  
  public var wrappedValue: Value {
    value(for: key)
  }
  
  public init(key: String,
              bundleReader: BundleReadable = BundleReader()) {
    self.key = key
    self.bundleReader = bundleReader
  }
}

private extension XCConfigValue {
  enum Error: Swift.Error {
    case missingKey(String)
    case invalidValue
    
    var description: String {
      switch self {
      case .missingKey(let key):
        return "Missing key: \(key)"
      case .invalidValue:
        return "Invalid Value"
      }
    }
  }
  
  func value(for key: String) -> Value {
    guard let object = bundleReader.object(forInfoDictionaryKey: key) else {
      fatalError(Error.missingKey(key).description)
    }
    
    switch object {
    case let value as Value:
      return value
    case let string as String:
      guard let value = Value(string) else {
        fatalError(Error.invalidValue.description)
      }
      return value
    default:
      fatalError(Error.invalidValue.description)
    }
  }
}
