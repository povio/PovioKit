//
//  URL+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
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
  /// Creates a `URL` object from a string literal.
  ///
  /// This initializer enables `URL` values to be initialized directly from string literals.
  /// If the literal is invalid, PovioKit emits an assertion failure in debug builds and falls
  /// back to `about:blank` instead of crashing in production.
  ///
  /// - Parameter value: A string literal representing a URL.
  /// - Warning: Invalid literals indicate a programmer error and should be fixed at the call site.
  ///
  /// ## Example
  /// ```swift
  /// let myURL: URL = "https://www.povio.com"
  /// print(myURL) // Prints: https://www.povio.com
  /// ```
  public init(stringLiteral value: String) {
    if let url = URL(string: value) {
      self = url
      return
    }
    #if DEBUG
    assertionFailure("Invalid URL string literal: \(value)")
    #endif
    self = URL(string: "about:blank")!
  }
}
