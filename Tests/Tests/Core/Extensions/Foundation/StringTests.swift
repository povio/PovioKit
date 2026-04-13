//
//  StringTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 05/05/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class StringTests: XCTestCase {
  func testLocalized() {
    XCTAssertEqual("this-doesn't exist".localized(), "this-doesn't exist")
  }
  
  func testTrimed() {
    XCTAssertEqual("  test".trimed, "test")
    XCTAssertEqual("test  ".trimed, "test")
    XCTAssertEqual("  test  ".trimed, "test")
    XCTAssertEqual("\n\n   test  \n\n".trimed, "test")
  }
  
  func testDigits() {
    XCTAssertEqual("abc123".digits, "123")
    XCTAssertEqual("123abc".digits, "123")
    XCTAssertEqual("abc123def".digits, "123")
    XCTAssertEqual("abc".digits, "")
    XCTAssertEqual("abc123?!*+-=".digits, "123")
  }
  
  func testBase64() {
    let string = "What a nice day we have :)"
    XCTAssertEqual(string.base64, "V2hhdCBhIG5pY2UgZGF5IHdlIGhhdmUgOik=")
  }
  
  func testIsEmail() {
    XCTAssertTrue("valid@email.com".isEmail)
    XCTAssertTrue("try.this+1@email.com".isEmail)
    XCTAssertFalse("invalid.email.com".isEmail)
    XCTAssertFalse("invalid@".isEmail)
    XCTAssertFalse("invalid@email".isEmail)
    XCTAssertFalse("@email.com".isEmail)
    XCTAssertFalse("invalid@@email.com".isEmail)
  }
  
  func testFirstNCharacters() {
    XCTAssertEqual("ThisIsATestString".safePrefix(0), "")
    XCTAssertEqual("ThisIsATestString".safePrefix(1), "T")
    XCTAssertEqual("ThisIsATestString".safePrefix(2), "Th")
    XCTAssertEqual("ThisIsATestString".safePrefix(4), "This")
    XCTAssertEqual("ThisIsATestString".safePrefix(100), "ThisIsATestString")
  }
  
  func testLastNCharacters() {
    XCTAssertEqual("ThisIsATestString".safeSuffix(0), "")
    XCTAssertEqual("ThisIsATestString".safeSuffix(1), "g")
    XCTAssertEqual("ThisIsATestString".safeSuffix(2), "ng")
    XCTAssertEqual("ThisIsATestString".safeSuffix(6), "String")
    XCTAssertEqual("ThisIsATestString".safeSuffix(100), "ThisIsATestString")
  }
  
  func testValidMarkdownConversion() {
    let markdownString = "**[BoldURL](https://povio.com)**"
    let expectedAttributedString = try! AttributedString(markdown: markdownString)

    let result = markdownString.toMarkdown()

    XCTAssertEqual(result, expectedAttributedString)
  }
  
  func testLines() {
    let value = "first\nsecond\r\nthird"
    XCTAssertEqual(value.lines.map(String.init), ["first", "second", "third"])
  }
  
  func testContainsEmoji() {
    XCTAssertTrue("Hello 👋".containsEmoji)
    XCTAssertFalse("Hello".containsEmoji)
  }
  
  func testInitials() {
    XCTAssertEqual("John Doe".initials, "JD")
    XCTAssertEqual("Elena Wayne Gomez".initials, "EG")
  }
}
