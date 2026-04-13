//
//  DateFormatterTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class DateFormatterTests: XCTestCase {
  
  // Test date: October 8, 2025, 9:41:30 PM (21:41:30)
  var testDate: Date!
  
  override func setUp() {
    super.setUp()
    
    // Create a consistent test date
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    var components = DateComponents()
    components.year = 2025
    components.month = 10
    components.day = 8
    components.hour = 21  // 9 PM in 24-hour format
    components.minute = 41
    components.second = 30
    components.timeZone = TimeZone(identifier: "UTC")
    
    testDate = calendar.date(from: components)!
  }
  
  override func tearDown() {
    testDate = nil
    super.tearDown()
  }
  
  // MARK: - Time Formatters
  
  func testTime12HourFormatter() {
    let formatter = DateFormatter.time12Hour
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "9:41 PM"
    XCTAssertTrue(result.contains("9:41"), "Should contain time 9:41")
    XCTAssertTrue(result.contains("PM") || result.contains("pm"), "Should contain PM indicator")
  }
  
  func testTime24HourFormatter() {
    let formatter = DateFormatter.time24Hour
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "21:41"
    XCTAssertEqual(result, "21:41", "Should format as 24-hour time")
  }
  
  // MARK: - Date Formatters
  
  func testLongDateFormatter() {
    let formatter = DateFormatter.longDate
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "October 8, 2025"
    XCTAssertTrue(result.contains("October"), "Should contain month name")
    XCTAssertTrue(result.contains("8"), "Should contain day")
    XCTAssertTrue(result.contains("2025"), "Should contain year")
  }
  
  func testAbbreviatedDateFormatter() {
    let formatter = DateFormatter.abbreviatedDate
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "Oct 8, 2025"
    XCTAssertTrue(result.contains("Oct"), "Should contain abbreviated month")
    XCTAssertTrue(result.contains("8"), "Should contain day")
    XCTAssertTrue(result.contains("2025"), "Should contain year")
  }
  
  func testIso8601DateFormatter() {
    let formatter = DateFormatter.iso8601Date
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "2025-10-08"
    XCTAssertEqual(result, "2025-10-08", "Should format as ISO 8601 date")
  }
  
  func testUsDateFormatter() {
    let formatter = DateFormatter.usDate
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "10/08/2025" (MM/dd/yyyy)
    XCTAssertEqual(result, "10/08/2025", "Should format as US date (MM/dd/yyyy)")
  }
  
  func testEuDateFormatter() {
    let formatter = DateFormatter.euDate
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "08/10/2025" (dd/MM/yyyy)
    XCTAssertEqual(result, "08/10/2025", "Should format as EU date (dd/MM/yyyy)")
  }
  
  func testRfc1123DateFormatter() {
    let formatter = DateFormatter.rfc1123Date
    formatter.timeZone = TimeZone(identifier: "GMT")
    
    let result = formatter.string(from: testDate)
    
    // Should format as "Wed, 08 Oct 2025 21:41:30 GMT"
    XCTAssertTrue(result.contains("Wed"), "Should contain day of week")
    XCTAssertTrue(result.contains("08 Oct 2025"), "Should contain date in RFC format")
    XCTAssertTrue(result.contains("21:41:30"), "Should contain time")
    XCTAssertTrue(result.contains("GMT"), "Should contain timezone")
  }
  
  // MARK: - Formatter Reusability Tests
  
  func testFormattersAreReusable() {
    let formatter = DateFormatter.iso8601Date
    formatter.timeZone = TimeZone(identifier: "UTC")
    
    let result1 = formatter.string(from: testDate)
    let result2 = formatter.string(from: testDate)
    
    XCTAssertEqual(result1, result2, "Formatter should produce consistent results")
  }
  
  func testFormattersAreDifferent() {
    // Ensure different formatters produce different output
    let iso = DateFormatter.iso8601Date
    let us = DateFormatter.usDate
    let eu = DateFormatter.euDate
    
    iso.timeZone = TimeZone(identifier: "UTC")
    us.timeZone = TimeZone(identifier: "UTC")
    eu.timeZone = TimeZone(identifier: "UTC")
    
    let isoResult = iso.string(from: testDate)
    let usResult = us.string(from: testDate)
    let euResult = eu.string(from: testDate)
    
    // All three should be different
    XCTAssertNotEqual(isoResult, usResult, "ISO and US formats should differ")
    XCTAssertNotEqual(isoResult, euResult, "ISO and EU formats should differ")
    XCTAssertNotEqual(usResult, euResult, "US and EU formats should differ")
  }
  
  // MARK: - Edge Cases
  
  func testFormatterWithLeapYear() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    var components = DateComponents()
    components.year = 2024  // Leap year
    components.month = 2
    components.day = 29  // Feb 29
    components.hour = 12
    components.timeZone = TimeZone(identifier: "UTC")
    
    let leapDate = calendar.date(from: components)!
    
    let formatter = DateFormatter.iso8601Date
    formatter.timeZone = TimeZone(identifier: "UTC")
    let result = formatter.string(from: leapDate)
    
    XCTAssertEqual(result, "2024-02-29", "Should handle leap year dates")
  }
  
  func testFormatterWithSingleDigitDay() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    var components = DateComponents()
    components.year = 2025
    components.month = 1
    components.day = 5  // Single digit
    components.hour = 12
    components.timeZone = TimeZone(identifier: "UTC")
    
    let singleDigitDate = calendar.date(from: components)!
    
    let usFormatter = DateFormatter.usDate
    usFormatter.timeZone = TimeZone(identifier: "UTC")
    let usResult = usFormatter.string(from: singleDigitDate)
    
    XCTAssertEqual(usResult, "01/05/2025", "Should zero-pad single digit day")
  }
  
  func testFormatterWithMidnight() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    var components = DateComponents()
    components.year = 2025
    components.month = 10
    components.day = 8
    components.hour = 0  // Midnight
    components.minute = 0
    components.timeZone = TimeZone(identifier: "UTC")
    
    let midnightDate = calendar.date(from: components)!
    
    let time24Formatter = DateFormatter.time24Hour
    time24Formatter.timeZone = TimeZone(identifier: "UTC")
    let result = time24Formatter.string(from: midnightDate)
    
    XCTAssertEqual(result, "0:00", "Should format midnight correctly")
  }
  
  func testFormatterWithNoon() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    
    var components = DateComponents()
    components.year = 2025
    components.month = 10
    components.day = 8
    components.hour = 12  // Noon
    components.minute = 0
    components.timeZone = TimeZone(identifier: "UTC")
    
    let noonDate = calendar.date(from: components)!
    
    let time12Formatter = DateFormatter.time12Hour
    time12Formatter.timeZone = TimeZone(identifier: "UTC")
    let result = time12Formatter.string(from: noonDate)
    
    XCTAssertTrue(result.contains("12:00"), "Should contain 12:00 for noon")
    XCTAssertTrue(result.contains("PM") || result.contains("pm"), "Noon should be PM")
  }
}

