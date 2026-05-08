//
//  MoneyTests.swift
//  PovioKit_Tests
//
//  Created by Marko Mijatovic on 04/07/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

final class MoneyTests: XCTestCase {
  // MARK: - Getters

  func testGetAmount() {
    let initialAmount: Money.Cents = 100
    let money = Money(amount: initialAmount, currency: .usd)
    XCTAssertEqual(money.amount, initialAmount)
  }

  func testGetCurrency() {
    let money = Money(amount: 100, currency: .usd)
    XCTAssertEqual(money.currency, .usd)
  }

  func testGetLocale() {
    let dinero = Money(amount: 100, currency: .eur, localeIdentifier: "es", precision: 2)
    XCTAssertEqual(dinero.locale.identifier, "es")
  }

  func testGetPrecision() {
    let money = Money(amount: 100, currency: .usd, precision: 3) // 0.1 $
    XCTAssertEqual(money.unitValue, 0.1)
  }

  func testGetFormatted() {
    var money = Money(amount: 123457, currency: .usd, localeIdentifier: "en_US")
    XCTAssertEqual(money.formatted, "$1,234.57")
    money.localeIdentifier = "es"
    XCTAssertEqual(money.formatted, "1234,57\u{00A0}US$")
  }

  func testCurrencyCode() {
    Currency.allCases.forEach { currency in
      let money = Money(amount: 100, currency: currency)
      XCTAssertEqual(money.currency.code, currency.code)
    }
  }

  func testCurrencySymbol() {
    Currency.allCases.forEach { currency in
      let money = Money(amount: 100, currency: currency)
      XCTAssertEqual(money.currency.symbol, currency.symbol)
    }
  }

  // MARK: - Arithmetic

  func testAddSameCurrencyDifferentPrecision() throws {
    let money = Money(amount: 100, currency: .usd)
    let other = Money(amount: 183456, currency: .usd, precision: 4)
    let sum = try money + other
    XCTAssertEqual(sum.unitValue, 19.3456, accuracy: 1e-6)
  }

  func testSubtractSameCurrencyDifferentPrecision() throws {
    let money = Money(amount: 2000, currency: .usd)
    let other = Money(amount: 183456, currency: .usd, precision: 4)
    let diff = try money - other
    XCTAssertEqual(diff.unitValue, 1.6544, accuracy: 1e-6)
  }

  func testAddDifferentCurrencyThrows() {
    let usd = Money(amount: 100, currency: .usd)
    let eur = Money(amount: 100, currency: .eur)

    XCTAssertThrowsError(try usd + eur) { error in
      guard case Money.ArithmeticError.currencyMismatch(let lhs, let rhs) = error else {
        XCTFail("Expected currencyMismatch, got \(error)")
        return
      }
      XCTAssertEqual(lhs, .usd)
      XCTAssertEqual(rhs, .eur)
    }
  }

  func testSubtractDifferentCurrencyThrows() {
    let usd = Money(amount: 100, currency: .usd)
    let eur = Money(amount: 100, currency: .eur)
    XCTAssertThrowsError(try usd - eur)
  }

  func testAddCentsScalar() {
    let money = Money(amount: 200, currency: .usd)
    XCTAssertEqual((money + 50).amount, 250)
    XCTAssertEqual((50 + money).amount, 250)
  }

  func testSubtractCentsScalar() {
    let money = Money(amount: 200, currency: .usd)
    XCTAssertEqual((money - 50).amount, 150)
  }

  func testMultiplyByInt() {
    let money = Money(amount: 200, currency: .usd)
    let quadruple = money * 4
    XCTAssertEqual(quadruple.unitValue, 8)
    XCTAssertEqual((4 * money).unitValue, 8)
  }

  // MARK: - Precision

  func testTrimPrecision() {
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimmedPrecision().precision, 0)
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimmedPrecision().amount, 2)
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimmedPrecision(), Money(amount: 2000, precision: 3))
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimmedPrecision(), Money(amount: 2, precision: 0))
  }

  func testTrimPrecisionResetsZeroAmount() {
    let initial = Money(amount: 0, currency: .usd, precision: 4)
    let trimmed = initial.trimmedPrecision()

    XCTAssertEqual(trimmed.amount, 0)
    XCTAssertEqual(trimmed.precision, 0)
    XCTAssertEqual(trimmed.currency, .usd)
  }

  /// The deprecated misspelled alias must keep returning the same
  /// canonical value as ``Money/trimmedPrecision()``. The test method
  /// itself is `@available(*, deprecated)` so the unavoidable
  /// deprecation warning at the call site does not surface as a build
  /// warning for the suite.
  @available(*, deprecated, message: "Validates the deprecated `trimedPrecision()` alias.")
  func testTrimedPrecisionDeprecatedAliasMatchesNewSpelling() {
    let original = Money(amount: 20000, currency: .eur, precision: 4)
    XCTAssertEqual(original.trimedPrecision(), original.trimmedPrecision())
  }

  // MARK: - Predicates

  func testIsPositiveExcludesZero() {
    XCTAssertFalse(Money(amount: 0, currency: .usd).isPositive)
    XCTAssertTrue(Money(amount: 1, currency: .usd).isPositive)
  }

  func testIsNegative() {
    XCTAssertTrue((Money(amount: 2000, currency: .usd) * -1).isNegative)
  }

  func testIsZero() {
    XCTAssertTrue(Money(amount: 0, currency: .usd).isZero)
  }

  // MARK: - Equality

  func testEqualityAlignsPrecision() {
    let money = Money(amount: 200, currency: .usd)              // 2.00 $
    let other = Money(amount: 2000, currency: .usd, precision: 3) // 2.000 $
    XCTAssertEqual(money, other)
  }

  func testNotEqualDifferentCurrency() {
    let money = Money(amount: 200, currency: .usd)
    let other = Money(amount: 2000, currency: .eur, precision: 3)
    XCTAssertNotEqual(money, other)
  }

  // MARK: - Hashable contract

  /// `Hashable` demands: if `a == b` then `a.hashValue == b.hashValue`.
  /// Previously, `==` aligned precision but the synthesised hash did not,
  /// which broke this invariant. Now both are defined via the trimmed
  /// canonical form, so the contract holds.
  func testEqualValuesProduceSameHash() {
    let money = Money(amount: 200, currency: .usd)                // 2.00 $
    let other = Money(amount: 2000, currency: .usd, precision: 3)  // 2.000 $
    XCTAssertEqual(money, other)
    XCTAssertEqual(money.hashValue, other.hashValue)
  }

  func testEqualValuesUsableInSets() {
    let money = Money(amount: 200, currency: .usd)
    let other = Money(amount: 2000, currency: .usd, precision: 3)
    let set: Set<Money> = [money, other]
    XCTAssertEqual(set.count, 1)
  }

  func testDifferentCurrenciesProduceDifferentHashes() {
    let usd = Money(amount: 200, currency: .usd)
    let eur = Money(amount: 200, currency: .eur)
    XCTAssertNotEqual(usd.hashValue, eur.hashValue)
  }

  // MARK: - Ordering

  func testIsGreaterThanSameCurrency() throws {
    let money = Money(amount: 200, currency: .usd)
    let other = Money(amount: 1990, currency: .usd, precision: 3)
    XCTAssertTrue(try money.isGreaterThan(other))
    XCTAssertTrue(try money.isGreaterThanOrEqual(to: other))
  }

  func testIsLessThanSameCurrency() throws {
    let money = Money(amount: 199, currency: .usd)
    let other = Money(amount: 2000, currency: .usd, precision: 3)
    XCTAssertTrue(try money.isLessThan(other))
    XCTAssertTrue(try money.isLessThanOrEqual(to: other))
  }

  func testOrderingThrowsOnMixedCurrencies() {
    let usd = Money(amount: 100, currency: .usd)
    let eur = Money(amount: 100, currency: .eur)
    XCTAssertThrowsError(try usd.isLessThan(eur))
    XCTAssertThrowsError(try usd.isGreaterThan(eur))
  }

  func testOrderingErrorCarriesMismatchedCurrencies() {
    let usd = Money(amount: 100, currency: .usd)
    let eur = Money(amount: 100, currency: .eur)

    XCTAssertThrowsError(try usd.isLessThan(eur)) { error in
      guard case Money.OrderingError.currencyMismatch(let lhs, let rhs) = error else {
        XCTFail("Expected OrderingError.currencyMismatch, got \(error)")
        return
      }
      XCTAssertEqual(lhs, .usd)
      XCTAssertEqual(rhs, .eur)
    }
  }

  func testOrderingBoundaryWhenEqual() throws {
    let lhs = Money(amount: 100, currency: .usd)
    let rhs = Money(amount: 1000, currency: .usd, precision: 3) // equal after alignment

    XCTAssertFalse(try lhs.isLessThan(rhs))
    XCTAssertFalse(try lhs.isGreaterThan(rhs))
    XCTAssertTrue(try lhs.isLessThanOrEqual(to: rhs))
    XCTAssertTrue(try lhs.isGreaterThanOrEqual(to: rhs))
  }

  // MARK: - Arithmetic symmetry

  /// Guards against a one-way bug in `alignToSamePrecision`.
  /// The existing tests cover `lhs.precision < rhs.precision`; this covers
  /// the reverse direction.
  func testAddHigherPrecisionOnLeft() throws {
    let higher = Money(amount: 183456, currency: .usd, precision: 4)
    let lower = Money(amount: 100, currency: .usd)
    let sum = try higher + lower
    XCTAssertEqual(sum.unitValue, 19.3456, accuracy: 1e-6)
  }

  func testSubtractHigherPrecisionOnLeft() throws {
    let higher = Money(amount: 183456, currency: .usd, precision: 4)
    let lower = Money(amount: 2000, currency: .usd)
    let diff = try higher - lower
    XCTAssertEqual(diff.unitValue, -1.6544, accuracy: 1e-6)
  }

  // MARK: - Hash equality beyond equality tests

  func testHashIgnoresLocaleIdentifier() {
    let us = Money(amount: 200, currency: .usd, localeIdentifier: "en_US")
    let es = Money(amount: 200, currency: .usd, localeIdentifier: "es")
    XCTAssertEqual(us, es)
    XCTAssertEqual(us.hashValue, es.hashValue)
  }

  func testZeroHashesEqualAcrossPrecisions() {
    let zeroP0 = Money(amount: 0, currency: .usd, precision: 0)
    let zeroP2 = Money(amount: 0, currency: .usd, precision: 2)
    let zeroP5 = Money(amount: 0, currency: .usd, precision: 5)

    XCTAssertEqual(zeroP0, zeroP2)
    XCTAssertEqual(zeroP0, zeroP5)
    XCTAssertEqual(zeroP0.hashValue, zeroP2.hashValue)
    XCTAssertEqual(zeroP0.hashValue, zeroP5.hashValue)

    let set: Set<Money> = [zeroP0, zeroP2, zeroP5]
    XCTAssertEqual(set.count, 1)
  }

  // MARK: - Codable

  /// Guards the on-disk representation. The coding keys are part of the
  /// wire format for any persisted Money (UserDefaults, backend payloads,
  /// documents) — a silent rename corrupts every existing value.
  func testCodableRoundTrip() throws {
    let original = Money(
      amount: 123_457,
      currency: .eur,
      localeIdentifier: "de_DE",
      precision: 3
    )

    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(Money.self, from: data)

    XCTAssertEqual(decoded.amount, original.amount)
    XCTAssertEqual(decoded.currency, original.currency)
    XCTAssertEqual(decoded.localeIdentifier, original.localeIdentifier)
    XCTAssertEqual(decoded.precision, original.precision)
  }

  func testCodableUsesStableKeys() throws {
    let money = Money(amount: 100, currency: .usd, localeIdentifier: "en_US", precision: 2)
    let data = try JSONEncoder().encode(money)
    let json = try XCTUnwrap(
      try JSONSerialization.jsonObject(with: data) as? [String: Any]
    )

    XCTAssertNotNil(json["cents"], "Coding key 'cents' is part of the persisted format; do not rename.")
    XCTAssertNotNil(json["currency"])
    XCTAssertNotNil(json["localeIdentifier"])
    XCTAssertNotNil(json["precision"])
  }
}
