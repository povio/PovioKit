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
  enum TestConfig {
    static let mockBundleReader = MockBundleReader(dictionary: ["TEST_STRING_KEY": "TEST_STRING_VALUE",
                                                                "TEST_INT_KEY": 1])
    
    
    @XCConfigValue(key: "TEST_STRING_KEY", bundleReader: mockBundleReader)
    static var testStringValue: String
    
    @XCConfigValue(key: "TEST_INT_KEY", bundleReader: mockBundleReader)
    static var testIntValue: Int
  }
  
  func testConfigValue() {
    XCTAssertEqual(TestConfig.testStringValue, "TEST_STRING_VALUE")
    XCTAssertEqual(TestConfig.testIntValue, 1)
  }
}
