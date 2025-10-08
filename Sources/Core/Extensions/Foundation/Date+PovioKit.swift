//
//  Date+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2024 Povio Inc. All rights reserved.
//

import Foundation

public extension Date {
  /// Checks if the date is today.
  ///
  /// - Returns: A boolean value indicating whether the date is today.
  var isToday: Bool { calendar.isDateInToday(self) }
  
  /// Checks if the date is yesterday.
  ///
  /// - Returns: A boolean value indicating whether the date is yesterday.
  var isYesterday: Bool { calendar.isDateInYesterday(self) }
  
  /// Checks if the date is in the future.
  ///
  /// - Returns: A boolean value indicating whether the date is in the future.
  var isInFuture: Bool { self > Date() }
  
  /// Gets the year component of the date.
  ///
  /// - Returns: An optional integer representing the year component of the date, or nil if it cannot be determined.
  var year: Int? { calendar.dateComponents([.year], from: self).year }

  /// Gets the month component of the date.
  ///
  /// - Returns: An optional integer representing the month component of the date, or nil if it cannot be determined.
  var month: Int? { calendar.dateComponents([.month], from: self).month }
  
  /// Gets the day component of the date.
  ///
  /// - Returns: An optional integer representing the day component of the date, or nil if it cannot be determined.
  var day: Int? { calendar.dateComponents([.day], from: self).day }
  
  /// Gets the start of the week for the date.
  ///
  /// - Returns: An optional Date representing the start of the week, or nil if it cannot be determined.
  var startOfWeek: Date? {
    let components: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear, .hour, .minute, .second, .nanosecond]
    return calendar.date(from: calendar.dateComponents(components, from: self))
  }
  
  /// Gets the end of the week for the date.
  ///
  /// - Returns: An optional Date representing the end of the week, or nil if it cannot be determined.
  var endOfWeek: Date? {
    guard let startOfWeek else { return nil }
    return calendar.date(byAdding: .day, value: 6, to: startOfWeek)
  }
}

// MARK: - Private Methods
private extension Date {
  var calendar: Calendar {
    Calendar.autoupdatingCurrent
  }
}
