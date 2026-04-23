//
//  BundleReader.swift
//  PovioKit
//
//  Created by Egzon Arifi on 31/03/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public protocol BundleReadable: Sendable {
  func object(forInfoDictionaryKey key: String) -> Any?
}

public final class BundleReader: BundleReadable, @unchecked Sendable {
  // `Bundle` is documented to be thread-safe for read access, and we
  // hold it immutably. `@unchecked Sendable` keeps the default
  // `BundleReader()` usable from `@XCConfigValue static var …`
  // declarations under Swift 6 strict concurrency.
  private let bundle: Bundle
  
  public init(bundle: Bundle = .main) {
    self.bundle = bundle
  }
  
  public func object(forInfoDictionaryKey key: String) -> Any? {
    bundle.object(forInfoDictionaryKey: key)
  }
}
