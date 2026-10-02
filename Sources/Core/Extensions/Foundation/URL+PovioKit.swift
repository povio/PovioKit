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
  /// The new name and value are percent-encoded with the query-allowed set,
  /// additionally escaping `+`, `&` and `=` (many servers treat a literal `+`
  /// as a space under `application/x-www-form-urlencoded` semantics). The
  /// existing query is appended to as-is and never re-serialised, so items
  /// already present (including form-encoded `+` spaces) are preserved and
  /// values can be composed through `appending` any number of times.
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
    // Append to the already-encoded query instead of re-serialising it, so
    // existing items (including form-encoded `+`) are preserved verbatim.
    // The new name/value get an explicit `+` escape — see doc comment above.
    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: "+&=")
    let encode = { (string: String) in string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string }
    var queryItems = components.percentEncodedQueryItems ?? []
    queryItems.append(URLQueryItem(name: encode(name), value: value.map(encode)))
    components.percentEncodedQueryItems = queryItems
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
