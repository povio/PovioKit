//
//  String+PovioKit.swift
//  PovioKit
//
//  Created by Povio Team on 26/04/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public extension String {
  /// Returns localized string for the current locale. If the key doesn't exist, `self` is returned.
  func localized(_ args: CVarArg...) -> String {
    guard !isEmpty else { return self }
    let localizedString = NSLocalizedString(self, comment: "")
    return withVaList(args) { NSString(format: localizedString, locale: Locale.current, arguments: $0) as String }
  }
  
  /// Trims whitespace and newlines from both ends.
  var trimmed: String {
    trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// Returns digits only from string
  var digits: String {
    components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
  }
  
  /// Returns base64 encoded string
  var base64: String? {
    data(using: .utf8)?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
  }
  
  /// Returns an array of substrings, where each string represents a line from the original string, split by a newline character.
  var lines: [Substring] {
    split(whereSeparator: \.isNewline)
  }
  
  /// Returns a boolean value indicating whether the string contains any emoji characters.
  var containsEmoji: Bool {
    unicodeScalars.contains { $0.properties.isEmojiPresentation }
  }
  
  /// Email validation
  var isEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
  
  /// Returns initials from string
  ///
  /// `John Doe` -> `JD`
  ///
  /// `Elena Wayne Gomez` -> `EWG`
  var initials: String {
    let formatter = PersonNameComponentsFormatter()
    if let components = formatter.personNameComponents(from: self) {
      formatter.style = .abbreviated
      return formatter.string(from: components)
    }
    return self
  }
  
  /// Returns substring containing up to `maxLength` characters from the beginning of the string.
  ///
  /// This method is just a wrapper around swift's standard library `prefix` method, but it ensures only positive values are accepted.
  func safePrefix(_ maxLength: UInt) -> Substring {
    prefix(Int(maxLength))
  }
  
  /// Returns substring containing up to `maxLength` characters from the end of the string.
  ///
  /// This method is just a wrapper around swift's standard library `suffix` method, but it ensures only positive values are accepted.
  func safeSuffix(_ maxLength: UInt) -> Substring {
    suffix(Int(maxLength))
  }
  
  /// Converts the string into a markdown formatted AttributedString.
  ///
  /// If the conversion fails (e.g., due to invalid markdown syntax), it returns the original string as an AttributedString.
  /// - Parameter options: Configures the markdown parsing behavior. Some developers have reported that the full parsing is too strict and sometimes
  /// doesn't render new lines. Use `.inlineOnlyPreservingWhitespace` for a more lenient parsing.
  /// - Precondition: Requires iOS 15 and above.
  func toMarkdown(
    options: AttributedString.MarkdownParsingOptions = AttributedString.MarkdownParsingOptions(
      interpretedSyntax: .full
    )
  ) -> AttributedString {
    do {
      return try AttributedString(markdown: self, options: options)
    } catch {
      return AttributedString(self)
    }
  }
}
