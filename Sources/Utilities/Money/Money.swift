//
//  Money.swift
//  PovioKit
//
//  Created by Marko Mijatovic on 04/05/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public struct Money: Hashable {
  public typealias Cents = Int
  
  /// Amount in minor currency units (eg. cents)
  public var amount: Cents
  /// ``Currency`` type that is containing the ISO code (eg. "USD") and symbol of the currency (eg. "$")
  public var currency: Currency
  /// The identifier for the Locale object that we use for the output formatting (eg. "en_US")
  public var localeIdentifier: String
  /// The number of decimal places to represent value
  public var precision: Int
  
  /**
   Initializes a new Money item with the provided amount and currency
   
   `localeIdentifier` and `precision` are not mandatory and we will use default values if not provided:
   - `localeIdentifier` default value is read from `Locale.current.identifier`
   - `precision` default value is 2, stored in `MoneyConstants.defaultPrecision`
   - Parameter cents: Amount value in minor currency units (eg. cents)
   - Parameter currency: ``Currency`` enum value of the supported currencies
   - Parameter localeIdentifier: Identifier for the Locale object that we use for the output formatting (eg. "en_US")
   - Parameter precision: The number of decimal places to represent value
   */
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

extension Money: Equatable, Comparable {
  public static func ==(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount == rhs.amount && lhs.currency == rhs.currency
  }

  public static func <(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount < rhs.amount && lhs.currency == rhs.currency
  }

  public static func >(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount > rhs.amount && lhs.currency == rhs.currency
  }

  public static func <=(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount <= rhs.amount && lhs.currency == rhs.currency
  }

  public static func >=(lhs: Money, rhs: Money) -> Bool {
    var lhs = lhs
    var rhs = rhs
    alignToSamePrecision(m1: &lhs, m2: &rhs)
    return lhs.amount >= rhs.amount && lhs.currency == rhs.currency
  }
}

// MARK: - Public Methods - Getters
public extension Money {
  /**
   Convert amount value (representing minor currency units) to the unit value based on the current precision
   ```swift
   // Example:
   // This returns 10.545
   Money(amount: 10545, currency: .usd, precision: 3).unitValue
   ```
   */
  var unitValue: Double {
    Double(amount) / pow(10, Double(precision))
  }
  
  /**
   Return unit value formatted with currently set locale
   ```swift
   // Example:
   // This returns $1,234.57
   Money(amount: 123457, currency: .usd, localeIdentifier: "en_US").formatted
   ```
   */
  var formatted: String? {
    unitValue.format(
      formatter: .init(),
      numberStyle: .currency,
      currencyCode: currency.code,
      precision: precision,
      locale: locale
    )
  }
  
  /// Locale object from the current _localeIdentifier_
  var locale: Locale {
    .init(identifier: localeIdentifier)
  }
  
  /**
   Return a new instance with precision trimed down to the safest possible scale.
   ```swift
   let m = Money(amount: 99250, precision: 4)
   let trimed = m.trimedPrecision()
   XCAssertEqual(trimed.amount, 9925)
   XCAssertEqual(trimed.precision, 3)
   ```
   */
  func trimedPrecision() -> Self {
    var res = self
    res.trimPrecision()
    return res
  }
  
  /**
   Trim the instance down to the safest possible scale.
   ```swift
   let m = Money(amount: 99250, precision: 4)
   m.trimPrecision()
   XCAssertEqual(m.amount, 9925)
   XCAssertEqual(m.precision, 3)
   ```
   */
  mutating func trimPrecision() {
    guard amount != .zero else { return }
    while precision > .zero, amount % 10 == 0 {
      amount /= 10
      precision -= 1
    }
  }
}

// MARK: - Public Methods - Testing
public extension Money {
  var isPositive: Bool {
    amount >= .zero
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

// MARK: - ExpressibleByFloatLiteral, CustomStringConvertible
extension Money: ExpressibleByFloatLiteral, CustomStringConvertible {
  /// Initialize a new Money instance from a literal.
  ///
  /// The literal gets automatically converted to Cents.
  /// We use `ExpressibleByFloatLiteral` instead of
  /// `ExpressibleByIntegerLiteral` so that multiplying by
  /// a factor works as expected.
  public init(floatLiteral cents: Double) {
    self.amount = Cents(cents)
    self.currency = Money.defaults.currency
    self.localeIdentifier = Money.defaults.locale.identifier
    self.precision = 2
  }
  
  public var description: String {
    return formatted ?? "\(amount) \(currency.symbol)"
  }
}

// MARK: - Math operators

/// A math operation to sum two `Money` objects.
/// - Important: Both objects need to be of the same `currency`!
/// - Important: *FatalError* will be raised when the currencies are not the same
/// - Returns: **New** Money object
public func + (_ lhs: Money, _ rhs: Money) -> Money {
  guard lhs.currency == rhs.currency else { fatalError("Currencies must be the same!") }
  var lhs = lhs
  var rhs = rhs
  alignToSamePrecision(m1: &lhs, m2: &rhs)
  return .init(
    amount: lhs.amount + rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision
  )
}

/// A math operation to divide two `Money` objects.
/// - Important: Both objects need to be of the same `currency`!
/// - Important: *FatalError* will be raised when the currencies are not the same
/// - Returns: **New** Money object
public func - (_ lhs: Money, _ rhs: Money) -> Money {
  guard lhs.currency == rhs.currency else { fatalError("Currencies must be the same!") }
  var lhs = lhs
  var rhs = rhs
  alignToSamePrecision(m1: &lhs, m2: &rhs)
  return .init(
    amount: lhs.amount - rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision)
}

/// A math operation to multiply two `Money` objects.
/// - Important: Both objects need to be of the same `currency`!
/// - Important: *FatalError* will be raised when the currencies are not the same
/// - Returns: **New** Money object
public func * (_ lhs: Money, _ rhs: Money) -> Money {
  guard lhs.currency == rhs.currency else { fatalError("Currencies must be the same!") }
  return .init(
    amount: lhs.amount * rhs.amount,
    currency: lhs.currency,
    localeIdentifier: lhs.localeIdentifier,
    precision: lhs.precision + rhs.precision)
}

// NOTE: - We do not support division, use multiplication instead!

/// A math operation to sum the `Money` object and the cents.
/// - Parameter rhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: rhs, currency: lhs.currency, precision: defaults.precision)
/// - Returns: **New** Money object
public func + (lhs: Money, rhs: Money.Cents) -> Money {
  let rhs = Money(amount: rhs, currency: lhs.currency, localeIdentifier: lhs.localeIdentifier, precision: Money.defaults.precision)
  return lhs + rhs
}

/// A math operation to sum cents and the `Money` object.
/// - Parameter lhs: The amount of cents to be added. It is converted to `Money`:  Money(amount: lhs, currency: rhs.currency, precision: defaults.precision)
/// - Returns: **New** Money object
public func + (lhs: Money.Cents, rhs: Money) -> Money {
  let lhs = Money(amount: lhs, currency: rhs.currency, localeIdentifier: rhs.localeIdentifier, precision: Money.defaults.precision)
  return lhs + rhs
}

/// A math operation to division of the `Money` object and the cents.
/// - Parameter rhs: The amount of cents to be substracted. It is converted to `Money`:  Money(amount: rhs, currency: lhs.currency, precision: defaults.precision)
/// - Returns: **New** Money object
public func - (lhs: Money, rhs: Money.Cents) -> Money {
  let rhs = Money(amount: rhs, currency: lhs.currency, localeIdentifier: lhs.localeIdentifier, precision: Money.defaults.precision)
  return lhs - rhs
}

/// A math operation to division of the cents and the `Money` object.
/// - Parameter rhs: The amount of cents to be substracted. It is converted to `Money`:  Money(amount: lhs, currency: rhs.currency, precision: defaults.precision)
/// - Returns: **New** Money object
public func - (lhs: Money.Cents, rhs: Money) -> Money {
  let lhs = Money(amount: lhs, currency: rhs.currency, localeIdentifier: rhs.localeIdentifier, precision: Money.defaults.precision)
  return lhs - rhs
}

/// A math operation to multiply the `Money` object with the Int multiplier.
/// - Parameter rhs: An integer multiplier.
/// - Returns: **New** Money object
public func * (_ lhs: Money, _ rhs: Int) -> Money {
  var res = lhs
  res.amount *= rhs
  return res
}
  
/// A math operation to multiply the `Money` object with the Int multiplier.
/// - Parameter lhs: An integer multiplier.
/// - Returns: **New** Money object
public func * (_ lhs: Int, _ rhs: Money) -> Money {
  var res = rhs
  res.amount *= lhs
  return res
}

/**
 Align precision for two Money objects.
 
 We will get maximum precision of the two and align another Money object to that value.
 */
fileprivate func alignToSamePrecision(m1: inout Money, m2: inout Money) {
  if m1.precision > m2.precision {
    m2.amount    = m2.amount * Money.Cents(pow(10, Double(m1.precision - m2.precision)))
    m2.precision = m1.precision
  } else if m1.precision < m2.precision {
    m1.amount    = m1.amount * Money.Cents(pow(10, Double(m2.precision - m1.precision)))
    m1.precision = m2.precision
  }
}
