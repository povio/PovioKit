//
//  DateTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class DateTests: XCTestCase {
  // MARK: - isToday
  
  func testIsToday() {
    let today = Date()
    XCTAssertTrue(today.isToday, "Current date should be today")
  }
  
  func testIsTodayForYesterday() {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
    XCTAssertFalse(yesterday.isToday, "Yesterday should not be today")
  }
  
  // MARK: - isYesterday
  
  func testIsYesterday() {
    let calendar = Calendar.current
    let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
    XCTAssertTrue(yesterday.isYesterday, "Yesterday should be identified as yesterday")
  }
  
  func testIsYesterdayForToday() {
    let today = Date()
    XCTAssertFalse(today.isYesterday, "Today should not be yesterday")
  }
  
  // MARK: - isInFuture
  
  func testIsInFuture() {
    let tomorrow = Date().addingTimeInterval(86400) // 24 hours
    XCTAssertTrue(tomorrow.isInFuture, "Tomorrow should be in the future")
  }
  
  func testIsInFutureForPast() {
    let yesterday = Date().addingTimeInterval(-86400) // -24 hours
    XCTAssertFalse(yesterday.isInFuture, "Yesterday should not be in the future")
  }
  
  // MARK: - Date Components
  
  func testYearComponent() {
    let calendar = Calendar.current
    let components = DateComponents(year: 2024, month: 10, day: 8)
    let date = calendar.date(from: components)!
    
    XCTAssertEqual(date.year, 2024, "Year should be 2024")
  }
  
  func testMonthComponent() {
    let calendar = Calendar.current
    let components = DateComponents(year: 2024, month: 10, day: 8)
    let date = calendar.date(from: components)!
    
    XCTAssertEqual(date.month, 10, "Month should be 10 (October)")
  }
  
  func testDayComponent() {
    let calendar = Calendar.current
    let components = DateComponents(year: 2024, month: 10, day: 8)
    let date = calendar.date(from: components)!
    
    XCTAssertEqual(date.day, 8, "Day should be 8")
  }
  
  // MARK: - Week Boundaries
  
  func testStartOfWeek() {
    let calendar = Calendar.current
    let components = DateComponents(year: 2024, month: 10, day: 8, hour: 15, minute: 30)
    let date = calendar.date(from: components)!
    
    guard let startOfWeek = date.startOfWeek else {
      XCTFail("startOfWeek should not be nil")
      return
    }
    
    XCTAssertNotNil(startOfWeek, "startOfWeek should return a date")
    
    // Verify the start of week is before or equal to the original date
    XCTAssertLessThanOrEqual(startOfWeek, date, "Start of week should be before or equal to the date")
  }
  
  func testEndOfWeek() {
    let calendar = Calendar.current
    let components = DateComponents(year: 2024, month: 10, day: 8, hour: 15, minute: 30)
    let date = calendar.date(from: components)!
    
    guard let endOfWeek = date.endOfWeek else {
      XCTFail("endOfWeek should not be nil")
      return
    }
    
    XCTAssertNotNil(endOfWeek, "endOfWeek should return a date")
    
    // Verify the end of week is after or equal to the original date
    XCTAssertGreaterThanOrEqual(endOfWeek, date, "End of week should be after or equal to the date")
  }
  
  func testEndOfWeekUsesCorrectInstance() {
    // This test verifies the bug fix: endOfWeek should use self.startOfWeek, not Date().startOfWeek
    let calendar = Calendar.current
    
    // Create a date in the past (January 1, 2024)
    let pastComponents = DateComponents(year: 2024, month: 1, day: 1)
    let pastDate = calendar.date(from: pastComponents)!
    
    // Get the end of week for the past date
    guard let pastEndOfWeek = pastDate.endOfWeek else {
      XCTFail("endOfWeek should not be nil")
      return
    }
    
    // The end of week should also be in January 2024, not in the current week
    let endOfWeekComponents = calendar.dateComponents([.year, .month], from: pastEndOfWeek)
    XCTAssertEqual(endOfWeekComponents.year, 2024, "End of week year should match the original date's year")
    XCTAssertEqual(endOfWeekComponents.month, 1, "End of week should be in the same month as the start of week")
    
    // Verify the end of week is not close to today
    let daysDifference = calendar.dateComponents([.day], from: pastEndOfWeek, to: Date()).day ?? 0
    XCTAssertGreaterThan(abs(daysDifference), 200, "End of week for past date should not be near today")
  }
  
  func testStartAndEndOfWeekConsistency() {
    let calendar = Calendar.current
    let testDate = Date()
    
    guard let startOfWeek = testDate.startOfWeek,
          let endOfWeek = testDate.endOfWeek else {
      XCTFail("Both startOfWeek and endOfWeek should return dates")
      return
    }
    
    // The difference between start and end of week should be 6 days
    let daysDifference = calendar.dateComponents([.day], from: startOfWeek, to: endOfWeek).day ?? 0
    XCTAssertEqual(daysDifference, 6, "End of week should be 6 days after start of week")
  }
}

