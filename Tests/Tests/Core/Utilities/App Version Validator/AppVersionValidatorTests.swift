//
//  AppVersionValidatorTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 16/02/2021.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class AppVersionValidatorTests: XCTestCase {
  func testValidator() {
    let validator = AppVersionValidator()
    XCTAssert(try validator.isAppVersion("1.8.4", equalOrHigherThan: "1.8.4"))
    XCTAssert(try validator.isAppVersion("1.8.5", equalOrHigherThan: "1.8.4"))
    XCTAssert(try validator.isAppVersion("1.9.4", equalOrHigherThan: "1.8.4"))
    XCTAssert(try validator.isAppVersion("2.0.0", equalOrHigherThan: "1.8.4"))
    XCTAssert(try validator.isAppVersion("1.9.0", equalOrHigherThan: "1.8.4"))
    XCTAssert(try validator.isAppVersion("2.0.0", equalOrHigherThan: "2"))
    XCTAssert(try validator.isAppVersion("2.0.1", equalOrHigherThan: "2"))
    XCTAssert(try validator.isAppVersion("2.2.2", equalOrHigherThan: "2"))
    XCTAssert(try validator.isAppVersion("2.2", equalOrHigherThan: "2"))
    XCTAssert(try validator.isAppVersion("2", equalOrHigherThan: "2"))
    XCTAssert(try validator.isAppVersion("3", equalOrHigherThan: "2.0.0.8"))
    XCTAssertFalse(try validator.isAppVersion("1.8.3", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(try validator.isAppVersion("1.7.9", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(try validator.isAppVersion("0.8.8", equalOrHigherThan: "1.8.4"))
    XCTAssertFalse(try validator.isAppVersion("1.9.9", equalOrHigherThan: "2"))
    XCTAssertFalse(try validator.isAppVersion("1.9", equalOrHigherThan: "2"))
    XCTAssertFalse(try validator.isAppVersion("1", equalOrHigherThan: "2"))
    XCTAssertFalse(try validator.isAppVersion("2", equalOrHigherThan: "2.0.0.8"))
    XCTAssertFalse(try validator.isAppVersion("2", equalOrHigherThan: "2.0.0.1"))
    
    XCTAssertThrowsError(try validator.isAppVersion("not a valid string", equalOrHigherThan: "1.0"))
    XCTAssertThrowsError(try validator.isAppVersion("a.b.c", equalOrHigherThan: "1.0"))
    XCTAssertThrowsError(try validator.isAppVersion("1.0", equalOrHigherThan: "not a valid string"))
    XCTAssertThrowsError(try validator.isAppVersion("1.0", equalOrHigherThan: "a.b.c"))
    XCTAssertThrowsError(try validator.isAppVersion("", equalOrHigherThan: "1.0"))
    XCTAssertThrowsError(try validator.isAppVersion("1.0", equalOrHigherThan: ""))
    XCTAssertThrowsError(try validator.isAppVersion("...", equalOrHigherThan: "2.0.0"))
    XCTAssertThrowsError(try validator.isAppVersion("1.v.5", equalOrHigherThan: "2.0.0"))
  }
}
