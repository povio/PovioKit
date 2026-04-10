# Money

Handle monetary values with ease.  
`Money` is a Swift implementation of the popular js library [Dinero.js](https://dinerojs.com/).

## Overview  

A Money is initialized with:
- **cents**: `Integer` - value in minor currency units (eg. cents)
- **currency**: `currency` - enum value of the supported currencies
- **localeIdentifier**: Optional `String` - identifier for the Locale object that we use for the output formatting (eg. "en_US"). If not provided, we will use `Locale.current.identifier` as default value.
- **precision**: Optional `Int` - number of decimal places to represent value, default value is 2.

### Getters:
- cents: Cents (typealias Cents = Int)
- currency: Currency
- localeIdentifier: String
- precision: Int
- unitValue: Double
- formatted: String?
- locale: Locale
### Manipulation:
- +, -, *, /
- multiply()
- divide()
- percentage()
- setLocaleIdentifier()
### Muttating Manipulations:
- multiply()
- divide()
- percentage()
- setLocaleIdentifier()
### Testing
- ==, >, >=, <, <= 
- isPositive
- isNegative
- isZero
- hasSameAmount()
- hasSameCurrency()
---
Additional: Confirmation to the protocols: Equatable, Comparable, Hashable, Codable, ExpressibleByIntegerLiteral, CustomStringConvertible    
  
---

## Support types  

We use couple additional types as a support for main `Money` struct:
- typealias Cents = Int
- enum `Currency`:
``` swift
public enum Currency: Codable {
  /// U.S. Dollar (USD)
  case usd
  /// European Euro (EUR)
  case eur
  /// Canadian Dollar (CAD)
  case cad
  /// Chinese Yuan Renminbi (CNY)
  case cny
  /// Japanese Yen (JPY)
  case jpy
  /// British Pound (GBP)
  case gbp
  /// Swiss Franc (CHF)
  case chf
}
```

For every `currency` we have params `code` and `symbol` to represent that Currency:
``` swift
var code: String {
  switch self {
  case .usd:
    return "USD"
    ///
  }
}

var symbol: String {
  switch self {
  case .usd:
    return "$"
    ///
  }
}
```

## Init

To initialize Money item, we call init method:  
``` swift
 // This represents 1$
let money = Money(amount: 100, currency: .usd, localeIdentifier: "en_US", precision: 2)
```
We can use default values and init same Money item like this:  
``` swift
 // This represents 1$
let money = Money(amount: 100, currency: .usd)
```  

## Precision
Because we store value in cents (minor currency unit) as an Integer, we also need to define the precision parameter as the number of decimal places to represent the unit value of the Money. This can lead to the different definitions of the same Money value, and we need to be aware of it when doing any of the manipulations:
``` swift
let money1 = Money(amount: 200, currency: .usd)  // 2 $
let money2 = Money(amount: 2000, currency: .usd, precision: 3)  // 2 $
let money3 = Money(amount: 20, currency: .usd, precision: 1) // 2 $
```

## Examples

### Formatting:
We can format String representation of the Money item with the locale and currency properties. This is how different localeIdentifier can format the same currency value:
``` swift 
let money = Money(amount: 123457, currency: .usd, localeIdentifier: "en_US")
print(money.formatted) // $1,234.57
let dinero = money.setLocaleIdentifier("es")
print(dinero.formatted) // 1234,57 US$
```

### Manipulations:  
> Note:  
> We can not do manipulations with Money items that have different currencies.  

We have set of *mutating* or *non-mutating* operations available on Money items.  
When calling immutable operations, we are always returning *new* Money item with applied operation as a result. That way we can also chain couple operations. For example:
``` swift
let money = Money(amount: 2000, currency: .usd, precision: 3)
  .multiply(4.5)
  .divide(3)
  .percentage(30)
print(money.formatted) // $0.99 = 2$ * 4.5 / 3 * 30%
```
We can also do manipulations on two Money items:
``` swift
let money = Money(amount: 200, currency: .usd) // 2 $
let other = Money(amount: 183456, currency: .usd, precision: 4) // 18.3456 $
let result = money * other // new Money item
print(result.unitValue) // 36.6912 $
```

### Comparison:
We can compare two Money items with standard comparison operators:
``` swift
let money1 = Money(amount: 200, currency: .usd)  // 2 $
let money2 = Money(amount: 1990, currency: .usd, precision: 3) // 1.99$
let money3 = Money(amount: 2000, currency: .usd, precision: 3)  // 2 $
print(money1 > money2) // true
print(money1 == money3) // true
print(money2 < money3) // true
```

## Source code
You can find source code here:
- [Money](/Sources/Utilities/Money/Money.swift)
- [Money+Currency](/Sources/Utilities/Money/Money+Currency.swift)
- [Money+Defaults](/Sources/Utilities/Money/Money+Defaults.swift)
- [Money+Extensions](/Sources/Utilities/Money/Money+Extensions.swift)
