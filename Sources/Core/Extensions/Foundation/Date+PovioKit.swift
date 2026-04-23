//
//  Date+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 14/05/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension Date {
  /// Checks if the date is today.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: A boolean value indicating whether the date is today.
  func isToday(using calendar: Calendar = .autoupdatingCurrent) -> Bool {
    calendar.isDateInToday(self)
  }
  
  /// Checks if the date is yesterday.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: A boolean value indicating whether the date is yesterday.
  func isYesterday(using calendar: Calendar = .autoupdatingCurrent) -> Bool {
    calendar.isDateInYesterday(self)
  }
  
  /// Checks if the date is in the future.
  var isInFuture: Bool { self > Date() }
  
  /// Gets the year component of the date.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: An optional integer representing the year component, or `nil`
  ///   if it cannot be determined.
  func year(using calendar: Calendar = .autoupdatingCurrent) -> Int? {
    calendar.dateComponents([.year], from: self).year
  }
  
  /// Gets the month component of the date.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: An optional integer representing the month component, or `nil`
  ///   if it cannot be determined.
  func month(using calendar: Calendar = .autoupdatingCurrent) -> Int? {
    calendar.dateComponents([.month], from: self).month
  }
  
  /// Gets the day component of the date.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: An optional integer representing the day component, or `nil`
  ///   if it cannot be determined.
  func day(using calendar: Calendar = .autoupdatingCurrent) -> Int? {
    calendar.dateComponents([.day], from: self).day
  }
  
  /// Gets the start of the week for the date.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: An optional `Date` representing the start of the week, or
  ///   `nil` if it cannot be determined.
  func startOfWeek(using calendar: Calendar = .autoupdatingCurrent) -> Date? {
    let components: Set<Calendar.Component> = [.yearForWeekOfYear, .weekOfYear, .hour, .minute, .second, .nanosecond]
    return calendar.date(from: calendar.dateComponents(components, from: self))
  }
  
  /// Gets the end of the week for the date.
  ///
  /// - Parameter calendar: The calendar used to interpret the date. Defaults
  ///   to `.autoupdatingCurrent`.
  /// - Returns: An optional `Date` representing the end of the week, or `nil`
  ///   if it cannot be determined.
  func endOfWeek(using calendar: Calendar = .autoupdatingCurrent) -> Date? {
    guard let start = startOfWeek(using: calendar) else { return nil }
    return calendar.date(byAdding: .day, value: 6, to: start)
  }
  
  // MARK: - Backwards-compatible property accessors
  
  /// Backwards-compatible alias for ``isToday(using:)``.
  ///
  /// - SeeAlso: ``isToday(using:)`` which accepts a custom calendar.
  var isToday: Bool { isToday() }
  
  /// Backwards-compatible alias for ``isYesterday(using:)``.
  ///
  /// - SeeAlso: ``isYesterday(using:)`` which accepts a custom calendar.
  var isYesterday: Bool { isYesterday() }
  
  /// Backwards-compatible alias for ``year(using:)``.
  ///
  /// - SeeAlso: ``year(using:)`` which accepts a custom calendar.
  var year: Int? { year() }
  
  /// Backwards-compatible alias for ``month(using:)``.
  ///
  /// - SeeAlso: ``month(using:)`` which accepts a custom calendar.
  var month: Int? { month() }
  
  /// Backwards-compatible alias for ``day(using:)``.
  ///
  /// - SeeAlso: ``day(using:)`` which accepts a custom calendar.
  var day: Int? { day() }
  
  /// Backwards-compatible alias for ``startOfWeek(using:)``.
  ///
  /// - SeeAlso: ``startOfWeek(using:)`` which accepts a custom calendar.
  var startOfWeek: Date? { startOfWeek() }
  
  /// Backwards-compatible alias for ``endOfWeek(using:)``.
  ///
  /// - SeeAlso: ``endOfWeek(using:)`` which accepts a custom calendar.
  var endOfWeek: Date? { endOfWeek() }
}
