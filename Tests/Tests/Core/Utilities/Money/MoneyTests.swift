//
//  MoneyTests.swift
//  PovioKit_Tests
//
//  Created by Marko Mijatovic on 04/07/2022.
//  Copyright © 2025 Povio Labs. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class MoneyTests: XCTestCase {
  // MARK: - Testing Getters
  func testGetAmount() {
    let initialAmount: Money.Cents = 100
    let money = Money(amount: initialAmount, currency: .usd)
    XCTAssertEqual(money.amount, initialAmount, "Money amount should be equal to initial value!")
  }
  
  func testGetCurrency() {
    let money = Money(amount: 100, currency: .usd)
    XCTAssertEqual(money.currency, .usd, "Money currency should be equal to initial value!")
  }
  
  func testSameCurrency() {
    let money = Money(amount: 100, currency: .usd)
    let dinero = Money(amount: 200, currency: .usd)
    XCTAssertEqual(money.currency, dinero.currency, "Two Money objects should have the same currencies!")
  }
  
  func testDifferentCurrency() {
    let money = Money(amount: 100, currency: .usd)
    let dinero = Money(amount: 200, currency: .eur)
    XCTAssertNotEqual(money.currency, dinero.currency, "Two Money objects should have different currencies!")
  }
  
  func testGetLocale() {
    let dinero = Money(amount: 100, currency: .eur, localeIdentifier: "es", precision: 2)
    XCTAssertEqual(dinero.locale.identifier, "es", "Money object should be with Spanish locale!")
  }
  
  func testGetPrecision() {
    let money = Money(amount: 100, currency: .usd, precision: 3) // 0.1 $
    XCTAssertEqual(money.unitValue, 0.1, "Money with 100 cents and precision 3 should have unit value of 0.1!")
  }
  
  func testGetFormatted() {
    var money = Money(amount: 123457, currency: .usd, localeIdentifier: "en_US")
    let formattedUS = money.formatted
    XCTAssertEqual(formattedUS, "$1,234.57", "Money should be formatted correctly!")
    money.localeIdentifier = "es"
    let formattedES = money.formatted
    XCTAssertEqual(formattedES, "1234,57 US$", "Money should be formatted correctly!")
  }
  
  func test_currencyCode() {
    Currency.allCases.forEach {
      let money = Money(amount: 100, currency: $0)
      XCTAssertEqual(money.currency.code, $0.code)
    }
  }
  
  func test_currencySymbol() {
    Currency.allCases.forEach {
      let money = Money(amount: 100, currency: $0)
      XCTAssertEqual(money.currency.symbol, $0.symbol)
    }
  }
  
  // MARK: - Testing Manipulations
  func testAdd() {
    let money = Money(amount: 100, currency: .usd) // 1 $
    let other = Money(amount: 183456, currency: .usd, precision: 4) // 18.3456 $
    let cents = (money + other).unitValue // This should be 193456 cents, or unit value of 19.3456 $
    XCTAssertEqual(cents, 19.3456, "Adding Money with different precision should be correct!")
  }

  func testSubtract() {
    let money = Money(amount: 2000, currency: .usd) // 20 $
    let other = Money(amount: 183456, currency: .usd, precision: 4) // 18.3456 $
    let unitValue = (money - other).unitValue // This should be 16544 cents, or unit value of 1.6544 $
    XCTAssertEqual(unitValue, 1.6544, "Subtract Money with different precision should be correct!")
  }
  
  func testMultiplyByNumber() {
    let money = Money(amount: 200, currency: .usd) // 2 $
    let moneyTimesFour = money * 4
    let unitValue = moneyTimesFour.unitValue // This should be 800 cents, or unit value of 8 $
    XCTAssertEqual(unitValue, 8, "Multiply Money by number should be correct!")
  }

  func testMultiply() {
    let money = Money(amount: 200, currency: .usd) // 2 $
    let other = Money(amount: 183456, currency: .usd, precision: 4) // 18.3456 $
    let unitValue = (money * other).unitValue // This should be 366912 cents, or unit value of 36.6912 $
    XCTAssertEqual(unitValue, 36.6912, "Multiply two Money objects should be correct!")
  }
  
  func testTax() {
    // https://v2.dinerojs.com/docs/core-concepts/scale
    let m1 = Money(amount: 1995, currency: .usd)
    let m2 = Money(amount: 55, currency: .usd, precision: 3)
    let total = m1 * m2 + m1
    XCTAssertEqual(total.unitValue, 21.04725)
  }
  
  func testTrimPrecision() {
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision().precision, 0)
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision().amount, 2)
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision(), Money(amount: 2000, precision: 3))
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision(), Money(amount: 200, precision: 2))
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision(), Money(amount: 20, precision: 1))
    XCTAssertEqual(Money(amount: 20000, precision: 4).trimedPrecision(), Money(amount: 2, precision: 0))
  }
  
  // MARK: - Testing Comparison
  func testIsPositive() {
    let money = Money(amount: 2000, currency: .usd)  // 20 $
    XCTAssertTrue(money.isPositive, "Money should be positive!")
    let debt = money * -1
    XCTAssertTrue(debt.isNegative, "Debt money should be negative!")
  }
  
  func testIsZero() {
    let money = Money(amount: 0, currency: .usd)
    XCTAssertTrue(money.isZero, "Money should be zero!")
  }
  
  func testIsEqual() {
    let money = Money(amount: 200, currency: .usd)  // 2 $
    let other = Money(amount: 2000, currency: .usd, precision: 3)  // 2 $
    XCTAssertTrue(money == other, "Two Money objects should be the same!")
    XCTAssertGreaterThanOrEqual(money, other, "One Money objects should be greater than or equal the other!")
    XCTAssertLessThanOrEqual(money, other, "One Money objects should be less than or equal the other!")
  }
  
  func testIsEqualDifferentCurrency() {
    let money = Money(amount: 200, currency: .usd)  // 2 $
    let other = Money(amount: 2000, currency: .eur, precision: 3)  // 2 €
    XCTAssertNotEqual(money, other, "Two Money objects with different currency should NOT be the same!")
  }
  
  func testIsGreater() {
    let money = Money(amount: 200, currency: .usd)  // 2 $
    let other = Money(amount: 1990, currency: .usd, precision: 3)  // 1.99 $
    XCTAssertGreaterThan(money, other, "One Money objects should be greater than the other!")
    XCTAssertGreaterThanOrEqual(money, other, "One Money objects should be greater than or equal the other!")
  }
  
  func testIsLess() {
    let money = Money(amount: 199, currency: .usd)  // 1.99 $
    let other = Money(amount: 2000, currency: .usd, precision: 3)  // 2 $
    XCTAssertLessThan(money, other, "One Money objects should be less than the other!")
    XCTAssertLessThanOrEqual(money, other, "One Money objects should be less than or equal the other!")
  }
  
  func testPerformance() {
    let m1 = Money(amount: 1995, currency: .usd)
    let m2 = Money(amount: 55, currency: .usd, precision: 3)

    func bench<T>(repeat: Int = 1_000_000, op: (Money, Money) -> T) {
      for _ in 0..<`repeat` {
        let _ = op(m1, m2)
      }
    }

    let timeAdd = benchmark { bench(op: +) }
    print("Done add")
    let timeSub = benchmark { bench(op: -) }
    print("Done sub")
    let timeMul = benchmark { bench(op: *) }
    print("Done mul")
    print(timeAdd, timeSub, timeMul)
  }
}

func benchmark(task: () -> Void) -> Double {
  let start = CFAbsoluteTimeGetCurrent()
  task()
  return CFAbsoluteTimeGetCurrent() - start
}
