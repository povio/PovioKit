//
//  DecodableDictionary+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

/// Decodable dictionary that can be used in case where the structure of given value is unknown.
/// Based on https://github.com/levantAJ/AnyCodable
///
/// ## Example
/// ```swift
/// struct MyResponse: Decodable {
///   let id: Int
///   let configuration: DecodableDictionary // dictionary with unknown key/value pairs
/// }
///
/// let configurationDictionary = myDeserializedResponse.configuration.dictionary // [String: Any]
/// ```
public struct DecodableDictionary: Decodable {
  public typealias Value = [String: Any]
  public let dictionary: Value
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: AnyCodingKey.self)
    dictionary = try container.decode(Value.self)
  }
}

public extension KeyedDecodingContainer {
  /// Decodes a collection of key-value pairs where the keys are strings and the values can be of any type.
  ///
  /// This method attempts to decode each key-value pair from a keyed container (e.g., `KeyedDecodingContainer`).
  /// For each key in the container, it tries to decode the value into different types (such as `Bool`, `String`, `Int`, `Double`, etc.),
  /// and stores the result in a dictionary with string keys and any type of values. If the value cannot be decoded into any
  /// of the known types, it moves on to the next type check.
  ///
  /// - Parameter type: The type to decode. This parameter is used to define the expected type of the decoded object.
  /// - Returns: A dictionary of key-value pairs where the key is a string and the value can be of any type.
  /// - Throws: It throws an error if the decoding process fails for any of the keys.
  ///
  /// ## Example
  /// ```swift
  /// let jsonString = """
  /// {
  ///   "name": "John Doe",
  ///   "age": 30,
  ///   "tags": ["developer", "swift"]
  /// }
  /// """
  /// let jsonData = jsonString.data(using: .utf8)!
  ///
  /// do {
  ///   let container = try JSONDecoder().container(keyedBy: CodingKeys.self, from: jsonData)
  ///   let decodedDictionary = try container.decode([String: Any].self)
  ///   Logger.debug(decodedDictionary)
  /// } catch {
  ///   Logger.error("Decoding error: \(error)")
  /// }
  /// ```
  func decode(_ type: [String: Any].Type) throws -> [String: Any] {
    var dictionary: [String: Any] = [:]
    for key in allKeys {
      if try decodeNil(forKey: key) {
        dictionary[key.stringValue] = NSNull()
      } else if let bool = try? decode(Bool.self, forKey: key) {
        dictionary[key.stringValue] = bool
      } else if let string = try? decode(String.self, forKey: key) {
        dictionary[key.stringValue] = string
      } else if let int = try? decode(Int.self, forKey: key) {
        dictionary[key.stringValue] = int
      } else if let double = try? decode(Double.self, forKey: key) {
        dictionary[key.stringValue] = double
      } else if let dict = try? decode([String: Any].self, forKey: key) {
        dictionary[key.stringValue] = dict
      } else if let array = try? decode([Any].self, forKey: key) {
        dictionary[key.stringValue] = array
      }
    }
    return dictionary
  }
  
  private func decode(_ type: [Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [Any] {
    var values = try nestedUnkeyedContainer(forKey: key)
    return try values.decode(type)
  }
  
  private func decode(_ type: [String: Any].Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> [String: Any] {
    try nestedContainer(keyedBy: AnyCodingKey.self, forKey: key).decode(type)
  }
}

public extension UnkeyedDecodingContainer {
  /// Decodes an array of elements of various types, including `Int`, `Bool`, `Double`, `String`,
  /// dictionaries (`[String: Any]`), and arrays (`[Any]`), from an unkeyed container.
  ///
  /// This method attempts to decode each element from the unkeyed container and appends it to an array.
  /// It supports a variety of types, including primitive types, nested dictionaries, and nested arrays.
  ///
  /// - Parameter type: The type to decode. This parameter is used to define the expected type of the decoded object.
  /// - Returns: An array of decoded elements, where each element can be of any type (e.g., `Int`, `Bool`, `String`, `[String: Any]`, etc.).
  /// - Throws: It throws an error if the decoding process fails for any of the elements in the unkeyed container.
  ///
  /// ## Example
  /// ```swift
  /// let jsonString = "[1, true, 2.5, "Hello", {"key": "value"}, [1, 2, 3]]"
  /// let jsonData = jsonString.data(using: .utf8)!
  /// 
  /// do {
  /// let container = try JSONDecoder().unkeyedContainer(from: jsonData)
  /// let decodedArray = try container.decode([Any].self)
  ///   Logger.debug(decodedArray)
  /// } catch {
  ///   Logger.error("Decoding error: \(error)")
  /// }
  /// ```
  mutating func decode(_ type: [Any].Type) throws -> [Any] {
    var elements: [Any] = []
    while !isAtEnd {
      if try decodeNil() {
        elements.append(NSNull())
      } else if let int = try? decode(Int.self) {
        elements.append(int)
      } else if let bool = try? decode(Bool.self) {
        elements.append(bool)
      } else if let double = try? decode(Double.self) {
        elements.append(double)
      } else if let string = try? decode(String.self) {
        elements.append(string)
      } else if let values = try? nestedContainer(keyedBy: AnyCodingKey.self),
                let element = try? values.decode([String: Any].self) {
        elements.append(element)
      } else if var values = try? nestedUnkeyedContainer(),
                let element = try? values.decode([Any].self) {
        elements.append(element)
      }
    }
    return elements
  }
}

// MARK: - Private Model
private struct AnyCodingKey: CodingKey {
  let stringValue: String
  private(set) var intValue: Int?
  
  init?(stringValue: String) { self.stringValue = stringValue }
  init?(intValue: Int) {
    self.intValue = intValue
    stringValue = String(intValue)
  }
}
