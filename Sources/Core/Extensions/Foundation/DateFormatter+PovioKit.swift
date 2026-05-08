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
  ///
  /// - Important: Returns a fresh formatter instance on each access to avoid
  /// shared mutable state across threads.
  static var time12Hour: DateFormatter {
    makeFormatter(with: "h:mm a")
  }
  
  /// Format a time in a 24-hour format without AM/PM designation.
  ///
  /// `9:41`
  static var time24Hour: DateFormatter {
    makeFormatter(with: "H:mm")
  }
  
  /// Format a date in a long format.
  ///
  /// `October 2, 2024`
  static var longDate: DateFormatter {
    makeFormatter(with: "MMMM d, yyyy")
  }
  
  /// Formats a date using an abbreviated format.
  ///
  /// `Oct 2, 2024`
  static var abbreviatedDate: DateFormatter {
    makeFormatter(with: "MMM d, yyyy")
  }
  
  /// Format a date using an ISO format.
  ///
  /// `2024-10-02`
  static var iso8601Date: DateFormatter {
    makeFormatter(with: "yyyy-MM-dd")
  }
  
  /// Formats a date using a US format.
  ///
  /// `10/02/2024`
  static var usDate: DateFormatter {
    makeFormatter(with: "MM/dd/yyyy")
  }
  
  /// Format a date using an EU format.
  ///
  /// `02/10/2024`
  static var euDate: DateFormatter {
    makeFormatter(with: "dd/MM/yyyy")
  }
  
  /// Format a date using an RFC 1123 format.
  ///
  /// `Tue, 02 Oct 2024 15:30:00 GMT`
  static var rfc1123Date: DateFormatter {
    makeFormatter(with: "EEE, dd MMM yyyy HH:mm:ss zzz")
  }
}

private extension DateFormatter {
  static func makeFormatter(with format: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = .autoupdatingCurrent
    dateFormatter.dateFormat = format
    return dateFormatter
  }
}
