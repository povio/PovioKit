//
//  DoubleTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 02/09/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class DoubleTests: XCTestCase {
  func test_convert_angles() {
    XCTAssertEqual(90.convert(from: UnitAngle.degrees, to: UnitAngle.radians), 90 * .pi / 180)
    XCTAssertEqual(90.convert(from: UnitAngle.degrees, to: UnitAngle.radians), 1.5707963267948966)
    XCTAssertEqual(1.5.convert(from: UnitAngle.radians, to: UnitAngle.degrees), 1.5 * 180 / .pi)
    XCTAssertEqual(1.5.convert(from: UnitAngle.radians, to: UnitAngle.degrees), 85.94366926962348)
  }
  
  func test_convert_length() {
    XCTAssertEqual(100.convert(from: UnitLength.miles, to: UnitLength.meters), 100 * 1609.344)
    XCTAssertEqual(100.convert(from: UnitLength.meters, to: UnitLength.miles), 100 / 1609.344)
  }
  
  func test_convert_weight() {
    XCTAssertEqual(1.5.convert(from: UnitMass.kilograms, to: UnitMass.grams), 1500)
    XCTAssertEqual(1500.convert(from: UnitMass.grams, to: UnitMass.kilograms), 1.5)
  }

  func testConvertWithDecodedUnit() throws {
    let encoded = try JSONEncoder().encode(Measurement(value: 1, unit: UnitLength.kilometers))
    let decoded = try JSONDecoder().decode(Measurement<UnitLength>.self, from: encoded)
    XCTAssertEqual(1.0.convert(from: decoded.unit, to: UnitLength.meters), 1000, accuracy: 0.0001)
    XCTAssertTrue(1.0.convert(from: UnitLength.meters, to: UnitMass.kilograms).isNaN)
  }
}
