//
//  Encodable+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public enum EncodableJSONError: Error, LocalizedError, Equatable {
  case invalidTopLevelObject
  
  public var errorDescription: String? {
    switch self {
    case .invalidTopLevelObject:
      return "Encoded payload is not a JSON object dictionary."
    }
  }
}

public extension Encodable {
  /// Encodes given encodable object into json/dictionary.
  ///
  /// ## Example
  /// ```swift
  /// struct Request: Encodable {}
  ///
  /// do {
  ///   let encoder = JSONEncoder()
  ///   let requestParameters = try request.toJSON(with: encoder)
  /// } catch {
  ///   // error
  /// }
  /// ```
  func toJSON(with encoder: JSONEncoder) throws -> [String: Any] {
    let data = try encoder.encode(self)
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    guard let dictionary = json as? [String: Any] else {
      throw EncodableJSONError.invalidTopLevelObject
    }
    return dictionary
  }
}
