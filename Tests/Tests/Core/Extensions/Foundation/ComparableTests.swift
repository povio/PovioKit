//
//  ComparableTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class ComparableTests: XCTestCase {
  // MARK: - clamped(to:) — integers

  func testClampedReturnsValueWhenInsideRange() {
    XCTAssertEqual(5.clamped(to: 0...10), 5)
  }

  func testClampedClampsToUpperBoundWhenAboveRange() {
    XCTAssertEqual(42.clamped(to: 0...10), 10)
  }

  func testClampedClampsToLowerBoundWhenBelowRange() {
    XCTAssertEqual((-7).clamped(to: 0...10), 0)
  }

  func testClampedReturnsBoundExactlyAtBoundary() {
    XCTAssertEqual(0.clamped(to: 0...10), 0)
    XCTAssertEqual(10.clamped(to: 0...10), 10)
  }

  func testClampedWithSinglePointRangeAlwaysReturnsThatPoint() {
    XCTAssertEqual((-5).clamped(to: 3...3), 3)
    XCTAssertEqual(3.clamped(to: 3...3), 3)
    XCTAssertEqual(99.clamped(to: 3...3), 3)
  }

  // MARK: - clamped(to:) — floating point and negative ranges

  func testClampedWithDoubleRange() {
    XCTAssertEqual(1.5.clamped(to: 0.0...1.0), 1.0)
    XCTAssertEqual(0.25.clamped(to: 0.0...1.0), 0.25)
  }

  func testClampedWithNegativeOnlyRange() {
    XCTAssertEqual(0.clamped(to: (-10)...(-1)), -1)
    XCTAssertEqual((-5).clamped(to: (-10)...(-1)), -5)
    XCTAssertEqual((-100).clamped(to: (-10)...(-1)), -10)
  }

  // MARK: - clamped(to:) — non-numeric Comparable

  func testClampedWithStrings() {
    XCTAssertEqual("apple".clamped(to: "banana"..."mango"), "banana")
    XCTAssertEqual("cherry".clamped(to: "banana"..."mango"), "cherry")
    XCTAssertEqual("orange".clamped(to: "banana"..."mango"), "mango")
  }
}
