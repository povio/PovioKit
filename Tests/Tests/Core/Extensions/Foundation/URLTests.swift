//
//  URLTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 05/05/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class URLTests: XCTestCase {
  func testInitWithOptionalString() {
    XCTAssertNil(URL(string: Optional<String>.none))
    XCTAssertEqual(URL(string: Optional("https://povio.com"))?.absoluteString, "https://povio.com")
  }

  func testInitWithString() {
    let urlString = "https://github.com/poviolabs/PovioKit"
    XCTAssertEqual(URL(string: urlString)?.absoluteString, urlString)
    XCTAssertNil(URL(string: "")?.absoluteString)
  }

  func testRequire() {
    let url = URL.require("https://github.com/poviolabs/PovioKit")
    XCTAssertEqual(url.absoluteString, "https://github.com/poviolabs/PovioKit")
  }

  func testRequireAcceptsCommonSchemes() {
    XCTAssertEqual(URL.require("https://povio.com").scheme, "https")
    XCTAssertEqual(URL.require("http://povio.com").scheme, "http")
    XCTAssertEqual(URL.require("file:///tmp/x").scheme, "file")
    XCTAssertEqual(URL.require("mailto:dev@povio.com").scheme, "mailto")
  }

  func testAppending() {
    let url = URL.require("https://github.com/poviolabs/PovioKit")
    let newUrl = url
      .appending("version", value: "0.4.0")
      .appending("build", value: "123&4$5-6")
      .appending("user", value: "John Doe")
      .appending("address", value: "Ljubljana+City")
    XCTAssertEqual(
      newUrl.absoluteString,
      "https://github.com/poviolabs/PovioKit?version=0.4.0&build=123%264$5-6&user=John%20Doe&address=Ljubljana%2BCity"
    )
  }

  func testQueryParameters() {
    let url = URL.require("https://povio.com?name=borut&team=ios")
    let params = url.queryParameters

    XCTAssertEqual(params?["name"], "borut")
    XCTAssertEqual(params?["team"], "ios")
  }

  func testQueryParametersReturnsNilWhenNoValues() {
    let url = URL.require("https://povio.com?empty")
    XCTAssertNil(url.queryParameters)
  }

  /// Calling `appending` repeatedly must not double-encode the query. The
  /// first call escapes `+` to `%2B`; the second call parses that back to
  /// `+` via `URLComponents` and re-escapes it — the outcome should be
  /// identical to a single-call encoding.
  func testAppendingIsIdempotentForPlus() {
    let once = URL.require("https://povio.com")
      .appending("token", value: "a+b")
    let twice = once
      .appending("note", value: "hello")

    XCTAssertEqual(once.absoluteString, "https://povio.com?token=a%2Bb")
    XCTAssertEqual(twice.absoluteString, "https://povio.com?token=a%2Bb&note=hello")
  }

  /// `appending` with a `nil` value must produce a bare name without `=`.
  func testAppendingNilValueProducesBareName() {
    let url = URL.require("https://povio.com").appending("flag", value: nil)
    XCTAssertEqual(url.absoluteString, "https://povio.com?flag")
  }

  /// Values containing URL-reserved characters must be properly encoded and
  /// must not be interpreted as additional query parameters.
  func testAppendingEncodesReservedCharacters() {
    let url = URL.require("https://povio.com")
      .appending("q", value: "a=b&c#d")

    XCTAssertEqual(url.queryParameters?["q"], "a=b&c#d")
  }

  /// Appending on a URL whose query already contains a previously-escaped
  /// `+` must preserve the original value.
  func testAppendingPreservesExistingEncodedPlus() {
    let url = URL.require("https://povio.com?token=a%2Bb")
      .appending("extra", value: "x")

    XCTAssertEqual(url.queryParameters?["token"], "a+b")
    XCTAssertEqual(url.queryParameters?["extra"], "x")
    XCTAssertEqual(url.absoluteString, "https://povio.com?token=a%2Bb&extra=x")
  }
}
