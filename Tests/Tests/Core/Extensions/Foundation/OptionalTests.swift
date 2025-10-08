//
//  OptionalTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest

class OptionalTests: XCTestCase {
  func test_arrayNilOrEmpty_returnsTrueWhenNil() {
    let sut: [String]? = nil
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when collection is nil")
  }
  
  func test_arrayNilOrEmpty_returnsTrueWhenEmpty() {
    let sut: [String]? = []
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when collection is empty")
  }
  
  func test_arrayNilOrEmpty_returnsFalseWhenNonEmpty() {
    let sut: [String]? = ["A"]
    XCTAssertFalse(sut.isNilOrEmpty, "Should not return true when collection is populated")
  }
  
  func test_stringNilOrEmpty_returnsTrueWhenNil() {
    let sut: String? = nil
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when string is nil")
  }
  
  func test_stringNilOrEmpty_returnsTrueWhenEmpty() {
    let sut: String? = ""
    XCTAssertTrue(sut.isNilOrEmpty, "Should not return false when string is empty")
  }
  
  func test_stringNilOrEmpty_returnsFalseWhenNonEmpty() {
    let sut: String? = "A"
    XCTAssertFalse(sut.isNilOrEmpty, "Should not return true when string contains characters")
  }
  
  func test_replacingString_producesExpectedResult() {
    let sut: String? = "Nice day today!"
    XCTAssertEqual(sut.replacingString(with: "night", range: NSRange(location: 5, length: 3)), "Nice night today!")
  }
  
  func test_replacingString_producesReplacementStringWhenNil() {
    let sut: String? = nil
    XCTAssertEqual(sut.replacingString(with: "night", range: NSRange(location: 0, length: 0)), "night")
  }
}
