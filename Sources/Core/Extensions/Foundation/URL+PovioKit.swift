//
//  URL+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension URL {
  /// A failable initializer for creating a `URL` object from an optional string.
  ///
  /// This initializer ensures that if the string is `nil`, the initialization fails
  /// and returns `nil`. It wraps the standard `URL(string:)` initializer, which only
  /// succeeds if the string can be parsed as a valid URL.
  ///
  /// - Parameter string: An optional string representing a URL.
  /// - Returns: A `URL` object if the string is non-`nil`, or `nil` if the string is `nil`.
  init?(string: String?) {
    guard let string = string else { return nil }
    self.init(string: string)
  }
  
  /// Append parameter to the URL.
  ///
  /// ## Example
  /// ```
  /// let someURL: URL = "https://povio.com"
  /// let newURL = someURL
  ///   .appending("accept", value: "developers")
  ///   .appending("tech", value: "iOS"
  ///
  /// print(newURL) // https://povio.com?accept=developers&tech=iOS
  /// ```
  func appending(_ name: String, value: String?) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return absoluteURL }
    var queryItems = components.queryItems ?? []
    let newQueryItem = URLQueryItem(name: name, value: value)
    queryItems.append(newQueryItem)
    components.queryItems = queryItems
    components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
    return components.url ?? absoluteURL
  }
  
  /// Retrieves the query parameters from the URL as a dictionary.
  ///
  /// - Returns: An optional dictionary where the keys are `AnyHashable` representing the query parameter names,
  ///            and the values are `Any` representing the corresponding query parameter values.
  ///            Returns nil if the URL is invalid or has no query parameters.
  var queryParameters: [AnyHashable: Any]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems else { return nil }
    
    var params = [AnyHashable: Any](minimumCapacity: queryItems.count)
    for queryItem in queryItems {
      if let value = queryItem.value {
        params[queryItem.name] = value
      }
    }
    
    return params.isEmpty ? nil : params
  }
}

extension URL: @retroactive ExpressibleByExtendedGraphemeClusterLiteral {}
extension URL: @retroactive ExpressibleByUnicodeScalarLiteral {}
extension Foundation.URL: Swift.ExpressibleByStringLiteral {
  /// A failable initializer that allows a `URL` object to be created from a string literal.
  ///
  /// This initializer enables a `URL` to be initialized directly from a string literal, which is
  /// especially useful when working with URL objects in a concise way. If the string is not a valid
  /// URL, it will trigger a runtime failure with a fatal error.
  ///
  /// - Parameter value: A string literal representing a URL.
  /// - Precondition: The string literal must represent a valid URL. Otherwise, the program will
  ///   terminate with a fatal error.
  ///
  /// ## Example
  /// ```swift
  /// let myURL: URL = "https://www.povio.com"
  /// print(myURL) // Prints: https://www.povio.com
  /// ```
  public init(stringLiteral value: String) {
    guard let url = URL(string: value) else {
      fatalError("Invalid URL string!")
    }
    self = url
  }
}
