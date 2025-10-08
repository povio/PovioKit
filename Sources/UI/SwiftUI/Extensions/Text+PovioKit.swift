//
//  Text+PovioKit.swift
//  PovioKit
//
//  Created by Yll Fejziu on 27/10/2023.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import PovioKitCore
import SwiftUI

public extension Text {
  /// Creates an instance of hyperlinked Text using markdown formatting syntax
  /// For dynamic strings, the link string has to be converted into an AttributedString
  /// https://developer.apple.com/videos/play/wwdc2021/10018/?time=1638
  init(_ text: String, link: String) {
    let markdownString = "[\(text)](\(link))".toMarkdown()

    self = Text(markdownString)
  }
}
