//
//  DateFormatter+PovioKit.swift
//  PovioKit
//
//  Created by Borut Tomazin on 02/10/2024.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension DateFormatter {
  /// Format a time in a 12-hour format with AM/PM designation.
  ///
  /// `9:41 PM`
  static let time12Hour: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "h:mm a"
    return dateFormatter
  }()
  
  /// Format a time in a 24-hour format without AM/PM designation.
  ///
  /// `9:41`
  static let time24Hour: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "H:mm"
    return dateFormatter
  }()
  
  /// Format a date in a long format.
  ///
  /// `October 2, 2024`
  static let longDate: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "MMMM d, yyyy"
    return dateFormatter
  }()
  
  /// Format a date in a abbreviated format.
  ///
  /// `Oct 2, 2024`
  static let abbreviatedDate: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "MMM d, yyyy"
    return dateFormatter
  }()
  
  /// Format a date using an ISO format.
  ///
  /// `2024-10-02`
  static let iso8601Date: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter
  }()
  
  /// Format a date using an US format.
  ///
  /// `10/02/2024`
  static let usDate: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter
  }()
  
  /// Format a date using an EU format.
  ///
  /// `02/10/2024`
  static let euDate: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "dd/MM/yyyy"
    return dateFormatter
  }()
  
  /// Format a date using an RFC 1123 format.
  ///
  /// `Tue, 02 Oct 2024 15:30:00 GMT`
  static let rfc1123Date: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    return dateFormatter
  }()
}
