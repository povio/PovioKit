//
//  MoneyDefaultsTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class MoneyDefaultsTests: XCTestCase {
  
  var originalDefaults: Money.Defaults!
  
  override func setUp() {
    super.setUp()
    // Save original defaults
    originalDefaults = Money.Defaults()
    originalDefaults.precision = defaults.precision
    originalDefaults.currency = defaults.currency
    originalDefaults.locale = defaults.locale
  }
  
  override func tearDown() {
    // Restore original defaults
    defaults.precision = originalDefaults.precision
    defaults.currency = originalDefaults.currency
    defaults.locale = originalDefaults.locale
    super.tearDown()
  }
  
  // MARK: - Default Values
  
  func testDefaultPrecision() {
    let moneyDefaults = Money.Defaults()
    XCTAssertEqual(moneyDefaults.precision, 2, "Default precision should be 2")
  }
  
  func testDefaultCurrency() {
    let moneyDefaults = Money.Defaults()
    XCTAssertEqual(moneyDefaults.currency, .usd, "Default currency should be USD")
  }
  
  func testDefaultLocale() {
    let moneyDefaults = Money.Defaults()
    XCTAssertEqual(moneyDefaults.locale, .current, "Default locale should be current")
  }
  
  // MARK: - Global Defaults
  
  func testGlobalDefaultsExist() {
    XCTAssertNotNil(defaults, "Global defaults should exist")
  }
  
  func testGlobalDefaultsInitialValues() {
    // Reset to ensure clean state
    defaults.precision = 2
    defaults.currency = .usd
    
    XCTAssertEqual(defaults.precision, 2, "Global defaults should have precision 2")
    XCTAssertEqual(defaults.currency, .usd, "Global defaults should have USD currency")
  }
  
  // MARK: - Modifying Global Defaults
  
  func testChangingDefaultPrecision() {
    defaults.precision = 3
    
    XCTAssertEqual(defaults.precision, 3, "Should be able to change default precision")
    
    // New Money instances should use new default
    let money = Money(amount: 1000)
    XCTAssertEqual(money.precision, 3, "New Money should use updated default precision")
  }
  
  func testChangingDefaultCurrency() {
    defaults.currency = .eur
    
    XCTAssertEqual(defaults.currency, .eur, "Should be able to change default currency")
    
    // New Money instances should use new default
    let money = Money(amount: 1000)
    XCTAssertEqual(money.currency, .eur, "New Money should use updated default currency")
  }
  
  func testChangingDefaultLocale() {
    let newLocale = Locale(identifier: "de_DE")
    defaults.locale = newLocale
    
    XCTAssertEqual(defaults.locale.identifier, "de_DE", "Should be able to change default locale")
    
    // New Money instances should use new default
    let money = Money(amount: 1000)
    XCTAssertEqual(money.localeIdentifier, "de_DE", "New Money should use updated default locale")
  }
  
  // MARK: - Multiple Changes
  
  func testChangingMultipleDefaults() {
    defaults.precision = 4
    defaults.currency = .gbp
    defaults.locale = Locale(identifier: "en_GB")
    
    XCTAssertEqual(defaults.precision, 4, "Precision should be updated")
    XCTAssertEqual(defaults.currency, .gbp, "Currency should be updated")
    XCTAssertEqual(defaults.locale.identifier, "en_GB", "Locale should be updated")
    
    // New Money instances should use all new defaults
    let money = Money(amount: 5000)
    XCTAssertEqual(money.precision, 4, "New Money should use updated precision")
    XCTAssertEqual(money.currency, .gbp, "New Money should use updated currency")
    XCTAssertEqual(money.localeIdentifier, "en_GB", "New Money should use updated locale")
  }
  
  // MARK: - Defaults Don't Affect Existing Instances
  
  func testChangingDefaultsDoesNotAffectExistingInstances() {
    // Create Money with initial defaults
    defaults.precision = 2
    defaults.currency = .usd
    let existingMoney = Money(amount: 1000, currency: .usd, precision: 2)
    
    // Change defaults
    defaults.precision = 4
    defaults.currency = .eur
    
    // Existing instance should remain unchanged
    XCTAssertEqual(existingMoney.precision, 2, "Existing Money precision should not change")
    XCTAssertEqual(existingMoney.currency, .usd, "Existing Money currency should not change")
  }
  
  // MARK: - Explicit Parameters Override Defaults
  
  func testExplicitParametersOverrideDefaults() {
    defaults.currency = .usd
    defaults.precision = 2
    
    // Explicit parameters should override defaults
    let money = Money(amount: 1000, currency: .eur, precision: 3)
    
    XCTAssertEqual(money.currency, .eur, "Explicit currency should override default")
    XCTAssertEqual(money.precision, 3, "Explicit precision should override default")
  }
  
  func testPartialExplicitParameters() {
    defaults.currency = .usd
    defaults.precision = 2
    defaults.locale = Locale(identifier: "en_US")
    
    // Only override currency, use defaults for others
    let money = Money(amount: 1000, currency: .eur)
    
    XCTAssertEqual(money.currency, .eur, "Explicit currency should be used")
    XCTAssertEqual(money.precision, 2, "Default precision should be used")
    XCTAssertEqual(money.localeIdentifier, "en_US", "Default locale should be used")
  }
  
  // MARK: - Edge Cases
  
  func testZeroPrecision() {
    defaults.precision = 0
    
    let money = Money(amount: 1000)
    XCTAssertEqual(money.precision, 0, "Should support zero precision")
    XCTAssertEqual(money.unitValue, 1000, "With precision 0, amount equals unit value")
  }
  
  func testHighPrecision() {
    defaults.precision = 8
    
    let money = Money(amount: 100000000)
    XCTAssertEqual(money.precision, 8, "Should support high precision")
    XCTAssertEqual(money.unitValue, 1.0, accuracy: 0.00000001, "Should handle high precision correctly")
  }
  
  func testDifferentLocales() {
    let locales = [
      "en_US",
      "de_DE",
      "fr_FR",
      "ja_JP",
      "zh_CN"
    ]
    
    for localeId in locales {
      defaults.locale = Locale(identifier: localeId)
      
      let money = Money(amount: 1000)
      XCTAssertEqual(money.localeIdentifier, localeId, "Should support \(localeId) locale")
    }
  }
  
  // MARK: - Defaults Struct Independence
  
  func testMultipleDefaultsInstancesAreIndependent() {
    var defaults1 = Money.Defaults()
    var defaults2 = Money.Defaults()
    
    defaults1.precision = 3
    defaults2.precision = 5
    
    XCTAssertEqual(defaults1.precision, 3, "defaults1 should have precision 3")
    XCTAssertEqual(defaults2.precision, 5, "defaults2 should have precision 5")
    XCTAssertNotEqual(defaults1.precision, defaults2.precision, "Instances should be independent")
  }
  
  // MARK: - Integration with Money Creation
  
  func testMoneyUsesDefaultsWhenNotSpecified() {
    defaults.currency = .cad
    defaults.precision = 3
    defaults.locale = Locale(identifier: "en_CA")
    
    let money = Money(amount: 12345)
    
    XCTAssertEqual(money.currency, .cad, "Money should use default currency")
    XCTAssertEqual(money.precision, 3, "Money should use default precision")
    XCTAssertEqual(money.localeIdentifier, "en_CA", "Money should use default locale")
    XCTAssertEqual(money.unitValue, 12.345, accuracy: 0.001, "Unit value should be calculated with default precision")
  }
}

