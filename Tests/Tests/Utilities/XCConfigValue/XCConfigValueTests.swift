//
//  XCConfigValueTests.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class XCConfigValueTests: XCTestCase {
  // The nested `TestConfig` namespace is `@MainActor`-isolated so that
  // `@XCConfigValue static var …` declarations satisfy Swift 6 strict
  // concurrency. Test methods below access these values synchronously
  // on the main thread (XCTest invokes test methods on the main queue
  // for `XCTestCase` subclasses), so the isolation is free at runtime.
  @MainActor
  enum TestConfig {
    static let mockBundleReader = MockBundleReader(dictionary: ["TEST_STRING_KEY": "TEST_STRING_VALUE",
                                                                "TEST_INT_KEY": 1,
                                                                "TEST_STRING_INT_KEY": "42"])
    static let emptyBundleReader = MockBundleReader(dictionary: [:])
    static let wrongTypeBundleReader = MockBundleReader(dictionary: ["WRONG_TYPE_KEY": Date()])
    
    @XCConfigValue(key: "TEST_STRING_KEY", bundleReader: mockBundleReader)
    static var testStringValue: String = "DEFAULT_STRING"
    
    @XCConfigValue(key: "TEST_INT_KEY", bundleReader: mockBundleReader)
    static var testIntValue: Int = -1
    
    @XCConfigValue(key: "TEST_STRING_INT_KEY", bundleReader: mockBundleReader)
    static var testStringIntValue: Int = -1
    
    @XCConfigValue(key: "MISSING_KEY", bundleReader: emptyBundleReader)
    static var missingValue: String = "FALLBACK"
    
    @XCConfigValue(key: "WRONG_TYPE_KEY", bundleReader: wrongTypeBundleReader)
    static var wrongTypeValue: Int = 99
  }
  
  @MainActor
  func testConfigValueReadsMatchingType() {
    XCTAssertEqual(TestConfig.testStringValue, "TEST_STRING_VALUE")
    XCTAssertEqual(TestConfig.testIntValue, 1)
  }
  
  @MainActor
  func testConfigValueParsesFromStringRepresentation() {
    XCTAssertEqual(TestConfig.testStringIntValue, 42)
  }
  
  @MainActor
  func testConfigValueReturnsDefaultWhenKeyIsMissing() {
    XCTAssertEqual(TestConfig.missingValue, "FALLBACK")
  }
  
  @MainActor
  func testConfigValueReturnsDefaultForUnconvertibleType() {
    XCTAssertEqual(TestConfig.wrongTypeValue, 99)
  }
}
