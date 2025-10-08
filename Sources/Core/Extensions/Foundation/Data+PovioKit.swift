//
//  Data+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 21/08/2020.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension Data {
  /// Returns a hexadecimal string representation of the data object.
  ///
  /// This property converts each byte of the data object into a two-character hexadecimal string. It is useful for tasks such as displaying raw binary data (e.g., a device token for push notifications) in a human-readable format.
  ///
  /// Useful for printing out device tokens, hashing results, or any scenario where raw data needs to be displayed as a hexadecimal string.
  ///
  /// - Returns: A string containing the hexadecimal representation of the data.
  ///
  /// ## Example
  /// ```swift
  /// let data = Data([0x01, 0xAB, 0xFF])
  /// Logger.debug(data.hexadecimalString) // "01abff"
  /// ```
  var hexadecimalString: String {
    map { String(format: "%02x", $0) }.joined()
  }
  
  /// Returns a UTF-8 encoded string from the data object.
  ///
  /// This property attempts to convert the `Data` object into a string using UTF-8 encoding. If the data is not valid UTF-8, it returns `nil`.
  ///
  /// - Returns: A UTF-8 encoded string if the conversion is successful, otherwise `nil`.
  ///
  /// ## Example
  /// ```swift
  /// let data = Data([0x48, 0x65, 0x6c, 0x6c, 0x6f])  // "Hello" in UTF-8
  /// if let string = data.utf8 {
  ///   Logger.debug(string) // "Hello"
  /// }
  /// ```
  var utf8: String? {
    String(data: self, encoding: .utf8)
  }
  
  /// Returns a UTF-16 encoded string from the data object.
  ///
  /// This property attempts to convert the `Data` object into a string using UTF-16 encoding. If the data is not valid UTF-16, it returns `nil`.
  ///
  /// - Returns: A UTF-16 encoded string if the conversion is successful, otherwise `nil`.
  ///
  /// - Example:
  /// ```swift
  /// let data = Data([0x00, 0x48, 0x00, 0x65, 0x00, 0x6c, 0x00, 0x6c, 0x00, 0x6f])  // "Hello" in UTF-16
  /// if let string = data.utf16 {
  ///   Logger.debug(string) // "Hello"
  /// }
  /// ```
  var utf16: String? {
    String(data: self, encoding: .utf16)
  }
  
  /// Decodes data to given `type` using given `decoder`.
  ///
  /// # Example
  /// ```swift
  /// let decodedUser = try responseData.decode(UserResponse.self, with: JSONDecoder())
  /// let decodedUser = try JSONDecoder().decode(UserResponse.self, from: responseData)
  /// ```
  func decode<D: Decodable>(_ type: D.Type, with decoder: JSONDecoder) throws -> D {
    try decoder.decode(type, from: self)
  }
}
