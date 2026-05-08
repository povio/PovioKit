//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/05/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public struct Money: Hashable, Sendable {
  public typealias Cents = Int

  /// Amount in minor currency units (eg. cents).
  public var amount: Cents
  /// ``Currency`` type, containing the ISO code (eg. "USD") and symbol (eg. "$").
  public var currency: Currency
  /// The identifier for the Locale object used for output formatting (eg. "en_US").
  public var localeIdentifier: String
  /// The number of decimal places to represent the value.
  public var precision: Int

  /// Initializes a new Money item with the provided amount and currency.
  ///
  /// - Parameters:
  ///   - amount: Value in minor currency units (eg. cents).
  ///   - currency: ``Currency`` enum value.
  ///   - localeIdentifier: Locale identifier used for formatting (eg. "en_US").
  ///   - precision: The number of decimal places to represent the value.
  public init(
    amount: Cents,
    currency: Currency = Money.defaults.currency,
    localeIdentifier: String = Money.defaults.locale.identifier,
    precision: Int = Money.defaults.precision
  ) {
    self.amount = amount
    self.currency = currency
    self.localeIdentifier = localeIdentifier
    self.precision = precision
  }
}

// MARK: - Equatable / Hashable

extension Money: Equatable {
  public static func == (lhs: Money, rhs: Money) -> Bool {
    guard lhs.currency == rhs.currency else { return false }
    var l = lhs
    var r = rhs
    alignToSamePrecision(m1: &l, m2: &r)
    return l.amount == r.amount
  }

  public func hash(into hasher: inout Hasher) {
    // Canonical form (trimmed precision) guarantees consistency with `==`:
    // any two Money values that compare equal hash to the same value.
    let normalized = trimmedPrecision()
    hasher.combine(normalized.amount)
    hasher.combine(normalized.precision)
    hasher.combine(normalized.currency)
  }
}

// MARK: - Ordering (same-currency only, not Comparable)
//
// We deliberately do NOT conform to `Comparable` because there is no total
// ordering across currencies. Compare same-currency values via the explicit
// throwing APIs below.

public extension Money {
  enum OrderingError: Error, Sendable {
    case currencyMismatch(Currency, Currency)
  }

  /// Throws ``OrderingError/currencyMismatch`` if the two values use
  /// different currencies.
  func isLessThan(_ other: Money) throws -> Bool {
    guard currency == other.currency else {
      throw OrderingError.currencyMismatch(currency, other.currency)
    }
    var l = self
    var r = other
    alignToSamePrecision(m1: &l, m2: &r)
    return l.amount < r.amount
  }

  func isGreaterThan(_ other: Money) throws -> Bool {
    try other.isLessThan(self)
  }

  func isLessThanOrEqual(to other: Money) throws -> Bool {
    try !isGreaterThan(other)
  }

  func isGreaterThanOrEqual(to other: Money) throws -> Bool {
    try !isLessThan(other)
  }
}

// MARK: - Getters
public extension Money {
  /// Convert amount to its unit value based on the current precision.
  var unitValue: Double {
    Double(amount) / pow(10, Double(precision))
  }

  /// Unit value formatted with the current locale, eg. "$1,234.57".
  var formatted: String? {
    unitValue.format(
      formatter: .init(),
      numberStyle: .currency,
      currencyCode: currency.code,
      precision: precision,
      locale: locale
    )
  }

  /// Locale object derived from ``localeIdentifier``.
  var locale: Locale {
    .init(identifier: localeIdentifier)
  }

  /// Returns a new instance with precision trimmed down to the safest
  /// possible scale.
  func trimmedPrecision() -> Self {
    var res = self
    res.trimPrecision()
    return res
  }

  /// Returns a new instance with precision trimmed down to the safest
  /// possible scale.
  ///
  /// Misspelled alias of ``trimmedPrecision()`` kept for backwards
  /// compatibility with callers that adopted the API before the typo was
  /// caught.
  @available(*, deprecated, renamed: "trimmedPrecision", message: "Use `trimmedPrecision()` (correct spelling). The old name is preserved for source compatibility and will be removed in a future major release.")
  func trimedPrecision() -> Self {
    trimmedPrecision()
  }

  /// Trims the precision in-place to the safest possible scale.
  mutating func trimPrecision() {
    guard amount != .zero else {
      precision = 0
      return
    }
    while precision > .zero, amount % 10 == 0 {
      amount /= 10
      precision -= 1
    }
  }
}

// MARK: - Predicates
public extension Money {
  /// True if the amount is strictly greater than zero.
  var isPositive: Bool {
    amount > .zero
  }

  var isNegative: Bool {
    amount < .zero
  }

  var isZero: Bool {
    amount == .zero
  }
}

// MARK: - Codable
extension Money: Codable {
  private enum CodingKeys: CodingKey {
    case cents, currency, localeIdentifier, precision
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    amount = try values.decode(Cents.self, forKey: .cents)
    currency = try values.decode(Currency.self, forKey: .currency)
    localeIdentifier = try values.decode(String.self, forKey: .localeIdentifier)
    precision = try values.decode(Int.self, forKey: .precision)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(amount, forKey: .cents)
    try container.encode(currency, forKey: .currency)
    try container.encode(localeIdentifier, forKey: .localeIdentifier)
    try container.encode(precision, forKey: .precision)
  }
}

// MARK: - CustomStringConvertible
extension Money: CustomStringConvertible {
  public var description: String {
    formatted ?? "\(amount) \(currency.symbol)"
  }
}

// MARK: - Arithmetic

public extension Money {
  enum ArithmeticError: Error, Sendable {
    case currencyMismatch(Currency, Currency)
  }

  /// Throwing addition. Both operands must share the same ``currency``.
  static func + (lhs: Money, rhs: Money) throws -> Money {
    guard lhs.currency == rhs.currency else {
      throw ArithmeticError.currencyMismatch(lhs.currency, rhs.currency)
    }
    var l = lhs
    var r = rhs
    alignToSamePrecision(m1: &l, m2: &r)
    return .init(
      amount: l.amount + r.amount,
      currency: l.currency,
      localeIdentifier: l.localeIdentifier,
      precision: l.precision
    )
  }

  /// Throwing subtraction. Both operands must share the same ``currency``.
  static func - (lhs: Money, rhs: Money) throws -> Money {
    guard lhs.currency == rhs.currency else {
      throw ArithmeticError.currencyMismatch(lhs.currency, rhs.currency)
    }
    var l = lhs
    var r = rhs
    alignToSamePrecision(m1: &l, m2: &r)
    return .init(
      amount: l.amount - r.amount,
      currency: l.currency,
      localeIdentifier: l.localeIdentifier,
      precision: l.precision
    )
  }

  /// Cents addition — adds minor units of the same currency.
  static func + (lhs: Money, rhs: Cents) -> Money {
    var res = lhs
    res.amount += rhs
    return res
  }

  /// Cents addition — adds minor units of the same currency.
  static func + (lhs: Cents, rhs: Money) -> Money {
    rhs + lhs
  }

  /// Cents subtraction — subtracts minor units of the same currency.
  static func - (lhs: Money, rhs: Cents) -> Money {
    var res = lhs
    res.amount -= rhs
    return res
  }

  /// Scalar multiplication.
  static func * (lhs: Money, rhs: Int) -> Money {
    var res = lhs
    res.amount *= rhs
    return res
  }

  /// Scalar multiplication.
  static func * (lhs: Int, rhs: Money) -> Money {
    rhs * lhs
  }
}

// MARK: - Helpers

/// Aligns two Money instances to the maximum precision of the two. The
/// operation is symmetric: both operands are mutated as needed.
///
/// We multiply by an integer power of ten rather than going through
/// `Double` + `pow(_:_:)` so that:
///   * the conversion is exact for every precision delta that fits in
///     `Money.Cents` (up to 18 for Int64), and
///   * any overflow traps deterministically rather than silently rounding
///     in the floating-point cast.
fileprivate func alignToSamePrecision(m1: inout Money, m2: inout Money) {
  if m1.precision > m2.precision {
    m2.amount *= integerPowerOfTen(m1.precision - m2.precision)
    m2.precision = m1.precision
  } else if m1.precision < m2.precision {
    m1.amount *= integerPowerOfTen(m2.precision - m1.precision)
    m1.precision = m2.precision
  }
}

/// Returns 10^exponent computed in `Money.Cents` (Int) without going
/// through floating point. Negative exponents are a programmer error
/// because the public callers always pass `max - min` of two precisions.
fileprivate func integerPowerOfTen(_ exponent: Int) -> Money.Cents {
  precondition(exponent >= 0, "integerPowerOfTen requires a non-negative exponent")
  var result: Money.Cents = 1
  for _ in 0..<exponent {
    result *= 10
  }
  return result
}
