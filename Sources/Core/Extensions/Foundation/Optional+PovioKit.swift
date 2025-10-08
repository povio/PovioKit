//
//  Optional+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation

public extension Optional where Wrapped: Collection {
  /// Checks if the optional collection is either `nil` or empty.
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
}

public extension Optional where Wrapped == String {
  /// Checks if the optional string is either `nil` or empty.
  var isNilOrEmpty: Bool {
    self?.isEmpty ?? true
  }
  
  /// Replace a substring in the optional string with a new string, given a range.
  func replacingString(with replacementString: String, range: NSRange) -> String {
    NSString(string: self ?? "").replacingCharacters(in: range, with: replacementString) as String
  }
}
