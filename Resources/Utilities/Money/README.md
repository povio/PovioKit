# Money

Handle monetary values with strict currency and precision semantics.  
`Money` is a lean Swift implementation inspired by [Dinero.js](https://dinerojs.com/).

## Overview

A `Money` value is initialised with:

- **amount**: `Cents` (typealias for `Int`) — value in minor currency units (e.g. cents).
- **currency**: `Currency` — enum of supported currencies. Defaults to `Money.defaults.currency`.
- **localeIdentifier**: `String` — identifier for the `Locale` used for output formatting (e.g. `"en_US"`). Defaults to `Money.defaults.locale.identifier`.
- **precision**: `Int` — number of decimal places in the unit value. Defaults to `Money.defaults.precision` (2).

### Stored properties

- `amount: Cents` (`typealias Cents = Int`)
- `currency: Currency`
- `localeIdentifier: String`
- `precision: Int`

### Derived properties

- `unitValue: Double` — `amount / 10ᵖʳᵉᶜⁱˢⁱᵒⁿ`.
- `formatted: String?` — unit value formatted with the current locale.
- `locale: Locale` — derived from `localeIdentifier`.
- `isPositive` (strictly `amount > 0`), `isNegative`, `isZero`.

### Methods

- `trimmedPrecision()` / `trimPrecision()` — trim trailing zeros in the
  canonical representation without changing the unit value. (The
  misspelled `trimedPrecision()` alias is preserved for backwards
  compatibility but is deprecated.)

### Arithmetic

- `Money + Money`, `Money - Money` — **throwing**; both operands must
  share the same currency. Throws
  `Money.ArithmeticError.currencyMismatch(lhs, rhs)` otherwise.
- `Money + Cents`, `Cents + Money`, `Money - Cents` — non-throwing,
  operates on minor units.
- `Money * Int`, `Int * Money` — non-throwing scalar multiplication.

### Ordering (throwing, same-currency only)

`Money` deliberately does **not** conform to `Comparable` — there is no
total order across currencies. Use the throwing helpers instead:

- `isLessThan(_:)`, `isGreaterThan(_:)`
- `isLessThanOrEqual(to:)`, `isGreaterThanOrEqual(to:)`

Each throws `Money.OrderingError.currencyMismatch` if operands disagree
on `currency`.

### Conformances

`Equatable`, `Hashable`, `Codable`, `Sendable`, `CustomStringConvertible`.

> **Breaking change in 7.0** — `Comparable`, `ExpressibleByFloatLiteral`,
> `ExpressibleByIntegerLiteral`, and the previous `Money * Money` /
> `Money / Money` operators have been removed. See
> [MIGRATING.md](/MIGRATING.md) for details.

## Support types

```swift
public enum Currency: Codable, Equatable, Hashable, CaseIterable, Sendable {
  case usd  // U.S. Dollar
  case eur  // European Euro
  case cad  // Canadian Dollar
  case cny  // Chinese Yuan Renminbi
  case jpy  // Japanese Yen
  case gbp  // British Pound
  case chf  // Swiss Franc
}
```

Each case exposes `code` (ISO) and `symbol`:

```swift
Currency.usd.code    // "USD"
Currency.usd.symbol  // "$"
```

## Defaults

Process-wide defaults live on `Money.defaults` (thread-safe):

```swift
Money.defaults.currency  = .eur
Money.defaults.precision = 2
Money.defaults.locale    = Locale(identifier: "sl_SI")
```

## Init

```swift
// 1 USD
let money = Money(amount: 100, currency: .usd, localeIdentifier: "en_US", precision: 2)

// Same value using defaults.
let money2 = Money(amount: 100, currency: .usd)
```

## Precision

Because amounts are stored in minor units as `Int`, the `precision`
parameter determines how many decimal places the unit value has. The
same unit value can therefore be spelled in several ways:

```swift
let a = Money(amount: 200,  currency: .usd)                 // $2
let b = Money(amount: 2000, currency: .usd, precision: 3)   // $2
let c = Money(amount: 20,   currency: .usd, precision: 1)   // $2
```

Arithmetic between values with different `precision` aligns them to the
higher precision internally; equality and hashing use a trimmed canonical
form, so `a == b == c`.

## Examples

### Formatting

```swift
let money = Money(amount: 123457, currency: .usd, localeIdentifier: "en_US")
money.formatted                          // "$1,234.57"
var relocalised = money
relocalised.localeIdentifier = "es"
relocalised.formatted                    // "1234,57 US$"
```

### Arithmetic between two `Money` values (throwing)

```swift
let invoice = Money(amount: 1_299, currency: .usd)
let tip     = Money(amount:   200, currency: .usd)
let eur     = Money(amount:   999, currency: .eur)

let total = try invoice + tip   // OK — $14.99
_ = try invoice + eur           // throws Money.ArithmeticError.currencyMismatch
```

### Cents and scalar arithmetic (non-throwing)

`Cents` and `Int` operands don't carry a currency, so these operators
don't need to throw:

```swift
let base = Money(amount: 1_000, currency: .usd)

base + 50       // $10.50  (Cents addition)
base - 250      // $7.50
base * 3        // $30
```

### Comparing two `Money` values

```swift
let money1 = Money(amount: 200,  currency: .usd)                 // $2
let money2 = Money(amount: 1_990, currency: .usd, precision: 3)  // $1.99
let money3 = Money(amount: 2_000, currency: .usd, precision: 3)  // $2

money1 == money3                    // true  (cross-precision equality)
try money1.isGreaterThan(money2)    // true
try money2.isLessThan(money3)       // true
```

## Source code

- [Money](/Sources/Utilities/Money/Money.swift)
- [Money+Currency](/Sources/Utilities/Money/Money+Currency.swift)
- [Money+Defaults](/Sources/Utilities/Money/Money+Defaults.swift)
- [Money+Extensions](/Sources/Utilities/Money/Money+Extensions.swift)
