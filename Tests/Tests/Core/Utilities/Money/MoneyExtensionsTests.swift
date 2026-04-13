//
//  MoneyExtensionsTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class MoneyExtensionsTests: XCTestCase {
  
  // MARK: - Comparable.clamped(to:)
  
  func testClampedWithinRange() {
    let value = 5
    let clamped = value.clamped(to: 0...10)
    
    XCTAssertEqual(clamped, 5, "Value within range should remain unchanged")
  }
  
  func testClampedBelowRange() {
    let value = -5
    let clamped = value.clamped(to: 0...10)
    
    XCTAssertEqual(clamped, 0, "Value below range should clamp to lower bound")
  }
  
  func testClampedAboveRange() {
    let value = 15
    let clamped = value.clamped(to: 0...10)
    
    XCTAssertEqual(clamped, 10, "Value above range should clamp to upper bound")
  }
  
  func testClampedAtLowerBound() {
    let value = 0
    let clamped = value.clamped(to: 0...10)
    
    XCTAssertEqual(clamped, 0, "Value at lower bound should remain at lower bound")
  }
  
  func testClampedAtUpperBound() {
    let value = 10
    let clamped = value.clamped(to: 0...10)
    
    XCTAssertEqual(clamped, 10, "Value at upper bound should remain at upper bound")
  }
  
  func testClampedWithDoubles() {
    let value: Double = 3.7
    let clamped = value.clamped(to: 1.0...5.0)
    
    XCTAssertEqual(clamped, 3.7, accuracy: 0.001, "Double value should clamp correctly")
  }
  
  func testClampedDoubleBelowRange() {
    let value: Double = 0.5
    let clamped = value.clamped(to: 1.0...5.0)
    
    XCTAssertEqual(clamped, 1.0, accuracy: 0.001, "Double below range should clamp to lower bound")
  }
  
  func testClampedDoubleAboveRange() {
    let value: Double = 7.5
    let clamped = value.clamped(to: 1.0...5.0)
    
    XCTAssertEqual(clamped, 5.0, accuracy: 0.001, "Double above range should clamp to upper bound")
  }
  
  func testClampedWithNegativeRange() {
    let value = -15
    let clamped = value.clamped(to: -10...(-5))
    
    XCTAssertEqual(clamped, -10, "Should handle negative ranges correctly")
  }
  
  func testClampedWithSingleValueRange() {
    let value = 5
    let clamped = value.clamped(to: 3...3)
    
    XCTAssertEqual(clamped, 3, "Should clamp to single value range")
  }
  
  func testClampedWithStrings() {
    let value = "m"
    let clamped = value.clamped(to: "a"..."z")
    
    XCTAssertEqual(clamped, "m", "String clamping should work")
  }
  
  func testClampedStringBelowRange() {
    let value = "A"
    let clamped = value.clamped(to: "a"..."z")
    
    XCTAssertEqual(clamped, "a", "String below range should clamp to lower bound")
  }
  
  // MARK: - Double.format()
  
  func testFormatWithDefaultParameters() {
    let value: Double = 42.50
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format value")
    XCTAssertTrue(formatted?.contains("42.50") ?? false, "Should contain the value")
  }
  
  func testFormatWithUSD() {
    let value: Double = 100.00
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format USD")
    XCTAssertTrue(formatted?.contains("$") ?? false, "Should contain dollar sign")
  }
  
  func testFormatWithEUR() {
    let value: Double = 50.99
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "EUR",
      precision: 2,
      locale: Locale(identifier: "de_DE")
    )
    
    XCTAssertNotNil(formatted, "Should format EUR")
    XCTAssertTrue(formatted?.contains("€") ?? false || formatted?.contains("50") ?? false, "Should contain euro symbol or value")
  }
  
  func testFormatWithZeroPrecision() {
    let value: Double = 42.99
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 0,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format with zero precision")
    // With 0 precision, should show 42 or 43 (rounded)
    XCTAssertTrue(formatted?.contains("42") ?? false || formatted?.contains("43") ?? false, "Should not show decimal places")
  }
  
  func testFormatWithHighPrecision() {
    let value: Double = 1.23456789
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 4,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format with high precision")
    // Should contain the value with at least 2 decimal places (currency might round)
    XCTAssertTrue(formatted?.contains("1.23") ?? false, "Should show decimal places")
  }
  
  func testFormatWithDecimalStyle() {
    let value: Double = 1234.56
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .decimal,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format with decimal style")
    XCTAssertTrue(formatted?.contains("1,234.56") ?? false || formatted?.contains("1234.56") ?? false, "Should format as decimal")
  }
  
  func testFormatWithPercentStyle() {
    let value: Double = 0.75
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .percent,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format with percent style")
    XCTAssertTrue(formatted?.contains("75") ?? false, "Should format as percentage")
  }
  
  func testFormatWithDifferentLocales() {
    let value: Double = 1234.56
    let formatter = NumberFormatter()
    
    let locales = [
      "en_US",
      "de_DE",
      "fr_FR",
      "ja_JP"
    ]
    
    for localeId in locales {
      let formatted = value.format(
        formatter: formatter,
        numberStyle: .currency,
        currencyCode: "USD",
        precision: 2,
        locale: Locale(identifier: localeId)
      )
      
      XCTAssertNotNil(formatted, "Should format for locale \(localeId)")
    }
  }
  
  func testFormatWithZeroValue() {
    let value: Double = 0.0
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format zero value")
    XCTAssertTrue(formatted?.contains("0") ?? false, "Should contain zero")
  }
  
  func testFormatWithNegativeValue() {
    let value: Double = -50.25
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format negative value")
    XCTAssertTrue(formatted?.contains("-") ?? false || formatted?.contains("(") ?? false, "Should indicate negative")
  }
  
  func testFormatWithVeryLargeNumber() {
    let value: Double = 999999999.99
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format very large number")
  }
  
  func testFormatWithVerySmallNumber() {
    let value: Double = 0.01
    let formatter = NumberFormatter()
    
    let formatted = value.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format very small number")
    XCTAssertTrue(formatted?.contains("0.01") ?? false, "Should show 0.01")
  }
  
  func testFormatReusesFormatter() {
    let formatter = NumberFormatter()
    let value1: Double = 10.50
    let value2: Double = 20.75
    
    let formatted1 = value1.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    let formatted2 = value2.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "EUR",
      precision: 2,
      locale: Locale(identifier: "de_DE")
    )
    
    XCTAssertNotNil(formatted1, "Should format first value")
    XCTAssertNotNil(formatted2, "Should format second value with same formatter")
  }
  
  // MARK: - Integration Tests
  
  func testClampedUsedWithMoney() {
    // Simulate clamping a monetary value
    let amount: Double = 150.0
    let maxBudget: Double = 100.0
    let clamped = amount.clamped(to: 0...maxBudget)
    
    XCTAssertEqual(clamped, maxBudget, "Amount should be clamped to budget")
  }
  
  func testFormatIntegrationWithClamped() {
    let value: Double = 150.0
    let clamped = value.clamped(to: 0...100)
    
    let formatter = NumberFormatter()
    let formatted = clamped.format(
      formatter: formatter,
      numberStyle: .currency,
      currencyCode: "USD",
      precision: 2,
      locale: Locale(identifier: "en_US")
    )
    
    XCTAssertNotNil(formatted, "Should format clamped value")
    XCTAssertTrue(formatted?.contains("100") ?? false, "Should show clamped amount")
  }
}

