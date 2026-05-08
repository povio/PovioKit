//
//  UIDeviceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitCore

// `UIDevice.current` and its properties are main-actor isolated in Swift 6.
@MainActor
class UIDeviceTests: XCTestCase {
  func testAppVariablesNotEmpty() {
    let sut = UIDevice.current
    XCTAssertFalse(sut.osVersion.isEmpty, "OS version should not be empty")
    XCTAssertFalse(sut.deviceName.isEmpty, "Device name should not be empty")
    XCTAssertFalse(sut.deviceCodeName.isEmpty, "Device code name should not be empty")
  }
}
#endif
