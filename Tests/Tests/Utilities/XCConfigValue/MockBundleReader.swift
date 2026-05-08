//
//  MockBundleReader.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation
import PovioKitCore
import PovioKitUtilities

final class MockBundleReader: BundleReadable, @unchecked Sendable {
  // `[String: Any]` is inherently non-Sendable, but `MockBundleReader`
  // holds it in a `let` and never mutates or publishes it after
  // construction, so `@unchecked Sendable` is sound for this test
  // helper.
  private let dictionary: [String: Any]
  
  init(dictionary: [String: Any]) {
    self.dictionary = dictionary
  }
  
  func object(forInfoDictionaryKey key: String) -> Any? {
    dictionary[key]
  }
}
