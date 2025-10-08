//
//  CurrencyTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class CurrencyTests: XCTestCase {
  
  // MARK: - Currency Codes
  
  func testUsdCode() {
    XCTAssertEqual(Currency.usd.code, "USD", "USD currency should have correct code")
  }
  
  func testEurCode() {
    XCTAssertEqual(Currency.eur.code, "EUR", "EUR currency should have correct code")
  }
  
  func testCadCode() {
    XCTAssertEqual(Currency.cad.code, "CAD", "CAD currency should have correct code")
  }
  
  func testCnyCode() {
    XCTAssertEqual(Currency.cny.code, "CNY", "CNY currency should have correct code")
  }
  
  func testJpyCode() {
    XCTAssertEqual(Currency.jpy.code, "JPY", "JPY currency should have correct code")
  }
  
  func testGbpCode() {
    XCTAssertEqual(Currency.gbp.code, "GBP", "GBP currency should have correct code")
  }
  
  func testChfCode() {
    XCTAssertEqual(Currency.chf.code, "CHF", "CHF currency should have correct code")
  }
  
  // MARK: - Currency Symbols
  
  func testUsdSymbol() {
    XCTAssertEqual(Currency.usd.symbol, "$", "USD should have $ symbol")
  }
  
  func testEurSymbol() {
    XCTAssertEqual(Currency.eur.symbol, "€", "EUR should have € symbol")
  }
  
  func testCadSymbol() {
    XCTAssertEqual(Currency.cad.symbol, "$", "CAD should have $ symbol")
  }
  
  func testCnySymbol() {
    XCTAssertEqual(Currency.cny.symbol, "¥", "CNY should have ¥ symbol")
  }
  
  func testJpySymbol() {
    XCTAssertEqual(Currency.jpy.symbol, "¥", "JPY should have ¥ symbol")
  }
  
  func testGbpSymbol() {
    XCTAssertEqual(Currency.gbp.symbol, "£", "GBP should have £ symbol")
  }
  
  func testChfSymbol() {
    XCTAssertEqual(Currency.chf.symbol, "Fr", "CHF should have Fr symbol")
  }
  
  // MARK: - CaseIterable
  
  func testAllCases() {
    let allCases = Currency.allCases
    
    XCTAssertEqual(allCases.count, 7, "Should have 7 currencies")
    XCTAssertTrue(allCases.contains(.usd), "Should contain USD")
    XCTAssertTrue(allCases.contains(.eur), "Should contain EUR")
    XCTAssertTrue(allCases.contains(.cad), "Should contain CAD")
    XCTAssertTrue(allCases.contains(.cny), "Should contain CNY")
    XCTAssertTrue(allCases.contains(.jpy), "Should contain JPY")
    XCTAssertTrue(allCases.contains(.gbp), "Should contain GBP")
    XCTAssertTrue(allCases.contains(.chf), "Should contain CHF")
  }
  
  func testAllCasesOrder() {
    let allCases = Currency.allCases
    
    // Test the order matches the enum declaration
    XCTAssertEqual(allCases[0], .usd, "First currency should be USD")
    XCTAssertEqual(allCases[1], .eur, "Second currency should be EUR")
    XCTAssertEqual(allCases[2], .cad, "Third currency should be CAD")
    XCTAssertEqual(allCases[3], .cny, "Fourth currency should be CNY")
    XCTAssertEqual(allCases[4], .jpy, "Fifth currency should be JPY")
    XCTAssertEqual(allCases[5], .gbp, "Sixth currency should be GBP")
    XCTAssertEqual(allCases[6], .chf, "Seventh currency should be CHF")
  }
  
  // MARK: - Equatable
  
  func testEquality() {
    XCTAssertEqual(Currency.usd, Currency.usd, "Same currency should be equal")
    XCTAssertNotEqual(Currency.usd, Currency.eur, "Different currencies should not be equal")
  }
  
  func testEqualityForAllCurrencies() {
    for currency in Currency.allCases {
      XCTAssertEqual(currency, currency, "\(currency) should equal itself")
    }
  }
  
  // MARK: - Hashable
  
  func testHashable() {
    let currencies: Set<Currency> = [.usd, .eur, .usd, .gbp, .eur]
    
    // Set should contain only unique values
    XCTAssertEqual(currencies.count, 3, "Set should contain 3 unique currencies")
    XCTAssertTrue(currencies.contains(.usd), "Set should contain USD")
    XCTAssertTrue(currencies.contains(.eur), "Set should contain EUR")
    XCTAssertTrue(currencies.contains(.gbp), "Set should contain GBP")
  }
  
  func testHashableAsKeys() {
    var dict: [Currency: String] = [:]
    
    dict[.usd] = "US Dollar"
    dict[.eur] = "Euro"
    dict[.gbp] = "Pound"
    
    XCTAssertEqual(dict[.usd], "US Dollar", "Should retrieve USD value")
    XCTAssertEqual(dict[.eur], "Euro", "Should retrieve EUR value")
    XCTAssertEqual(dict[.gbp], "Pound", "Should retrieve GBP value")
    XCTAssertNil(dict[.jpy], "Should return nil for missing key")
  }
  
  // MARK: - Codable
  
  func testEncodeDecode() throws {
    let currencies = Currency.allCases
    
    for currency in currencies {
      let encoder = JSONEncoder()
      let data = try encoder.encode(currency)
      
      let decoder = JSONDecoder()
      let decoded = try decoder.decode(Currency.self, from: data)
      
      XCTAssertEqual(decoded, currency, "\(currency) should encode and decode correctly")
    }
  }
  
  func testEncodeDecodeInArray() throws {
    let currencies: [Currency] = [.usd, .eur, .gbp]
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(currencies)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([Currency].self, from: data)
    
    XCTAssertEqual(decoded, currencies, "Array of currencies should encode/decode correctly")
  }
  
  func testEncodeDecodeInDictionary() throws {
    let dict: [String: Currency] = [
      "primary": .usd,
      "secondary": .eur
    ]
    
    let encoder = JSONEncoder()
    let data = try encoder.encode(dict)
    
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([String: Currency].self, from: data)
    
    XCTAssertEqual(decoded["primary"], .usd, "Should decode USD correctly")
    XCTAssertEqual(decoded["secondary"], .eur, "Should decode EUR correctly")
  }
  
  // MARK: - Code and Symbol Consistency
  
  func testAllCurrenciesHaveNonEmptyCode() {
    for currency in Currency.allCases {
      XCTAssertFalse(currency.code.isEmpty, "\(currency) should have non-empty code")
      XCTAssertEqual(currency.code.count, 3, "\(currency) code should be 3 characters (ISO 4217)")
    }
  }
  
  func testAllCurrenciesHaveNonEmptySymbol() {
    for currency in Currency.allCases {
      XCTAssertFalse(currency.symbol.isEmpty, "\(currency) should have non-empty symbol")
    }
  }
  
  func testCodesAreUppercase() {
    for currency in Currency.allCases {
      XCTAssertEqual(currency.code, currency.code.uppercased(), "\(currency) code should be uppercase")
    }
  }
  
  func testCodesAreUnique() {
    let codes = Currency.allCases.map { $0.code }
    let uniqueCodes = Set(codes)
    
    XCTAssertEqual(codes.count, uniqueCodes.count, "All currency codes should be unique")
  }
  
  // MARK: - Symbols Can Be Shared
  
  func testSomeSymbolsAreShared() {
    // USD and CAD both use $
    XCTAssertEqual(Currency.usd.symbol, Currency.cad.symbol, "USD and CAD should share $ symbol")
    
    // CNY and JPY both use ¥
    XCTAssertEqual(Currency.cny.symbol, Currency.jpy.symbol, "CNY and JPY should share ¥ symbol")
  }
}

