//
//  UserDefault.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value: Codable> {
  private let storage: UserDefaults
  private let keyObject: UserDefaultKey<Value>
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  
  public var wrappedValue: Value {
    get {
      // try to read as primitive type first (for @AppStorage compatibility)
      if let primitiveValue = readPrimitive() {
        return primitiveValue
      }
      
      // try to read as JSON-encoded Data
      if let data = storage.data(forKey: keyObject.key) {
        if let value = try? decoder.decode(Value.self, from: data) {
          return value
        }
      }
      
      // check for legacy non-encoded stored value
      if let oldValue = storage.object(forKey: keyObject.key) as? Value {
        // migrate to new format if it's a complex type
        if !isPrimitiveType(Value.self) {
          if let encoded = try? encoder.encode(oldValue) {
            storage.set(encoded, forKey: keyObject.key)
          }
        }
        return oldValue
      }
      
      // return default value if no value is set
      return keyObject.defaultValue
    }
    set {
      if storePrimitive(newValue) { // store primitive types directly (for @AppStorage compatibility)
        // successfully stored as primitive
      } else { // store complex types as JSON-encoded Data
        if let encoded = try? encoder.encode(newValue) {
          storage.set(encoded, forKey: keyObject.key)
        }
      }
    }
  }
  
  public init(
    defaultValue: Value,
    key: String,
    storage: UserDefaults = .standard,
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
  ) {
    self.storage = storage
    self.encoder = encoder
    self.decoder = decoder
    self.keyObject = UserDefaultKey(
      key: key,
      defaultValue: defaultValue,
      storage: storage,
      encoder: encoder
    )
  }
  
  public var projectedValue: UserDefaultKey<Value> {
    keyObject
  }
}

// MARK: - Private Helpers
private extension UserDefault {
  func isPrimitiveType(_ type: Any.Type) -> Bool {
    type is Bool.Type ||
    type is Int.Type ||
    type is Double.Type ||
    type is Float.Type ||
    type is String.Type ||
    type is Data.Type ||
    type is Date.Type ||
    type is URL.Type
  }
  
  func storePrimitive(_ value: Value) -> Bool {
    switch value {
    case let boolValue as Bool:
      storage.set(boolValue, forKey: keyObject.key)
      return true
    case let intValue as Int:
      storage.set(intValue, forKey: keyObject.key)
      return true
    case let doubleValue as Double:
      storage.set(doubleValue, forKey: keyObject.key)
      return true
    case let floatValue as Float:
      storage.set(floatValue, forKey: keyObject.key)
      return true
    case let stringValue as String:
      storage.set(stringValue, forKey: keyObject.key)
      return true
    case let dataValue as Data:
      storage.set(dataValue, forKey: keyObject.key)
      return true
    case let dateValue as Date:
      storage.set(dateValue, forKey: keyObject.key)
      return true
    case let urlValue as URL:
      storage.set(urlValue, forKey: keyObject.key)
      return true
    default:
      return false
    }
  }
  
  func readPrimitive() -> Value? {
    // For primitive types that never return nil (Bool, Int, Double, Float),
    // we need to check if the key exists first, otherwise we'd return
    // the UserDefaults default (false/0) instead of our defaultValue
    let keyExists = storage.object(forKey: keyObject.key) != nil
    
    if Value.self is Bool.Type {
      return keyExists ? storage.bool(forKey: keyObject.key) as? Value : nil
    } else if Value.self is Int.Type {
      return keyExists ? storage.integer(forKey: keyObject.key) as? Value : nil
    } else if Value.self is Double.Type {
      return keyExists ? storage.double(forKey: keyObject.key) as? Value : nil
    } else if Value.self is Float.Type {
      return keyExists ? storage.float(forKey: keyObject.key) as? Value : nil
    } else if Value.self is String.Type {
      return storage.string(forKey: keyObject.key) as? Value
    } else if Value.self is Data.Type {
      return storage.data(forKey: keyObject.key) as? Value
    } else if Value.self is Date.Type {
      return storage.object(forKey: keyObject.key) as? Value
    } else if Value.self is URL.Type {
      return storage.url(forKey: keyObject.key) as? Value
    }
    return nil
  }
}

public class UserDefaultKey<Value: Codable> {
  public let key: String
  public let defaultValue: Value
  public let storage: UserDefaults
  public let encoder: JSONEncoder
  
  init(
    key: String,
    defaultValue: Value,
    storage: UserDefaults,
    encoder: JSONEncoder
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.storage = storage
    self.encoder = encoder
  }
  
  public func resetValue() {
    // Try to reset as primitive first
    switch defaultValue {
    case let boolValue as Bool:
      storage.set(boolValue, forKey: key)
    case let intValue as Int:
      storage.set(intValue, forKey: key)
    case let doubleValue as Double:
      storage.set(doubleValue, forKey: key)
    case let floatValue as Float:
      storage.set(floatValue, forKey: key)
    case let stringValue as String:
      storage.set(stringValue, forKey: key)
    case let dataValue as Data:
      storage.set(dataValue, forKey: key)
    case let dateValue as Date:
      storage.set(dateValue, forKey: key)
    case let urlValue as URL:
      storage.set(urlValue, forKey: key)
    default:
      // Reset complex types as JSON
      if let encoded = try? encoder.encode(defaultValue) {
        storage.set(encoded, forKey: key)
      }
    }
  }
}
