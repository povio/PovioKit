//
//  URL+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension URL {
  /// A failable initializer for creating a `URL` from an optional string.
  ///
  /// Returns `nil` if `string` is `nil` or cannot be parsed as a URL.
  init?(string: String?) {
    guard let string = string else { return nil }
    self.init(string: string)
  }

  /// Creates a URL from a string literal, trapping on invalid input.
  ///
  /// This is intended as an explicit, opt-in replacement for the retroactive
  /// `ExpressibleByStringLiteral` conformance the package used to ship, which
  /// turned *every* string literal context involving `URL` into a surprise
  /// site of failure. Use ``URL/require(_:file:line:)`` at the call site
  /// where you know the input is static and must be valid.
  ///
  /// ## Example
  /// ```swift
  /// let home = URL.require("https://povio.com")
  /// ```
  static func require(
    _ string: String,
    file: StaticString = #fileID,
    line: UInt = #line
  ) -> URL {
    guard let url = URL(string: string) else {
      preconditionFailure("Invalid URL literal: \(string)", file: file, line: line)
    }
    return url
  }

  /// Appends a query parameter to the URL.
  ///
  /// The implementation relies on `URLComponents` for all percent-encoding
  /// except for the literal `+`, which `URLComponents` intentionally leaves
  /// unencoded even though many servers treat it as a space under
  /// `application/x-www-form-urlencoded` semantics. The `+` fixup operates
  /// on `percentEncodedQuery`, so it is idempotent and does not double-encode
  /// other characters — values can be composed or round-tripped through
  /// `appending` any number of times without corruption.
  ///
  /// ## Example
  /// ```swift
  /// let someURL = URL.require("https://povio.com")
  /// let newURL = someURL
  ///   .appending("accept", value: "developers")
  ///   .appending("tech", value: "iOS")
  /// // https://povio.com?accept=developers&tech=iOS
  /// ```
  func appending(_ name: String, value: String?) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
      // `URLComponents(url:resolvingAgainstBaseURL:)` only fails for malformed
      // URLs; in that case we can't reasonably attach a query parameter, so
      // return the original URL unchanged.
      return self
    }
    var queryItems = components.queryItems ?? []
    queryItems.append(URLQueryItem(name: name, value: value))
    components.queryItems = queryItems
    // Explicit `+` escape — see doc comment above. Not doing this means the
    // value round-trips fine on Apple platforms but gets silently corrupted
    // on form-encoded server parsers.
    if let encodedQuery = components.percentEncodedQuery {
      components.percentEncodedQuery = encodedQuery.replacingOccurrences(of: "+", with: "%2B")
    }
    return components.url ?? self
  }

  /// Retrieves the query parameters from the URL as a typed dictionary.
  ///
  /// - Returns: A `[String: String]` dictionary of query items that have a
  ///   non-`nil` value, or `nil` if the URL has no parameters.
  var queryParameters: [String: String]? {
    guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
          let queryItems = components.queryItems else { return nil }

    var params = [String: String](minimumCapacity: queryItems.count)
    for item in queryItems {
      if let value = item.value {
        params[item.name] = value
      }
    }

    return params.isEmpty ? nil : params
  }
}
