//
//  UserDefault.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore

@propertyWrapper
public struct UserDefault<Value: Codable>: @unchecked Sendable {
  // The wrapper is marked `@unchecked Sendable` so it is usable on
  // `static var` declarations under Swift 6 strict concurrency. That
  // is sound for all stored fields:
  //   * `storage` (`UserDefaults`) is documented to be thread-safe.
  //   * `keyObject` is immutable after construction.
  //   * `JSONEncoder` / `JSONDecoder` are used only for their default
  //     configuration; neither of them is mutated through this wrapper.
  // `wrappedValue`'s setter is `nonmutating` so that the synthesized
  // backing storage can be `let`, which is the whole reason the
  // `static var` pattern is accepted by Swift 6.
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
        do {
          return try decoder.decode(Value.self, from: data)
        } catch {
          Logger.error(
            "UserDefault failed to decode stored value; falling back to the legacy path.",
            params: ["key": keyObject.key, "error": error.localizedDescription]
          )
        }
      }

      // check for legacy non-encoded stored value
      if let oldValue = storage.object(forKey: keyObject.key) as? Value {
        // migrate to new format if it's a complex type
        if !isPrimitiveType(Value.self) {
          do {
            let encoded = try encoder.encode(oldValue)
            storage.set(encoded, forKey: keyObject.key)
          } catch {
            Logger.error(
              "UserDefault failed to migrate legacy stored value to JSON; value will be re-migrated on next read.",
              params: ["key": keyObject.key, "error": error.localizedDescription]
            )
          }
        }
        return oldValue
      }
      
      // return default value if no value is set
      return keyObject.defaultValue
    }
    nonmutating set {
      if storePrimitive(newValue) { // store primitive types directly (for @AppStorage compatibility)
        return
      }
      // store complex types as JSON-encoded Data
      do {
        let encoded = try encoder.encode(newValue)
        storage.set(encoded, forKey: keyObject.key)
      } catch {
        // We can't throw from a property-wrapper setter, but we must not
        // silently drop the user's write — log it so the failure is
        // actionable in release builds.
        Logger.error(
          "UserDefault failed to encode value; the write was dropped.",
          params: ["key": keyObject.key, "error": error.localizedDescription]
        )
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
    let storedObject = storage.object(forKey: keyObject.key)
    let keyExists = storedObject != nil
    
    // For Bool, Int, Double, Float: if stored value is Data, it might be JSON-encoded
    // from a previous version. Skip primitive reading and let JSON decoding handle it.
    // Note: We only check this for types where storage.bool/integer/double/float(forKey:)
    // would return a wrong default (false/0) instead of nil when Data is stored.
    let storedAsData = storedObject is Data
    
    if Value.self is Bool.Type {
      guard keyExists && !storedAsData else { return nil }
      return storage.bool(forKey: keyObject.key) as? Value
    } else if Value.self is Int.Type {
      guard keyExists && !storedAsData else { return nil }
      return storage.integer(forKey: keyObject.key) as? Value
    } else if Value.self is Double.Type {
      guard keyExists && !storedAsData else { return nil }
      return storage.double(forKey: keyObject.key) as? Value
    } else if Value.self is Float.Type {
      guard keyExists && !storedAsData else { return nil }
      return storage.float(forKey: keyObject.key) as? Value
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

public final class UserDefaultKey<Value: Codable>: @unchecked Sendable {
  // `@unchecked Sendable` is sound: all stored properties are `let`,
  // `UserDefaults` is documented to be thread-safe, and `JSONEncoder`
  // is used only for its existing configuration — never mutated.
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
      do {
        let encoded = try encoder.encode(defaultValue)
        storage.set(encoded, forKey: key)
      } catch {
        Logger.error(
          "UserDefault failed to encode default value during reset; the key was not cleared.",
          params: ["key": key, "error": error.localizedDescription]
        )
      }
    }
  }
}
