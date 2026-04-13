//
//  AppVersionValidator.swift
//  Alamofire
//
//  Created by Toni Kocjan on 16/02/2021.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Foundation

public final class AppVersionValidator {
  public init() {}
  
  /// Validate given app version with minimum required version:
  ///
  /// Examples:
  ///  XCTAssert(validator.isAppVersion("1.8.4", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.8.5", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.9.4", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("1.9.0", equalOrHigherThan: "1.8.4"))
  ///  XCTAssert(validator.isAppVersion("2.0.0", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.0.1", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.2.2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2.2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("2", equalOrHigherThan: "2"))
  ///  XCTAssert(validator.isAppVersion("3", equalOrHigherThan: "2.0.0.8"))
  ///  XCTAssertFalse(validator.isAppVersion("1.8.3", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("1.7.9", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("0.8.8", equalOrHigherThan: "1.8.4"))
  ///  XCTAssertFalse(validator.isAppVersion("1.9.9", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("1.9", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("1", equalOrHigherThan: "2"))
  ///  XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.8"))
  ///  XCTAssertFalse(validator.isAppVersion("2", equalOrHigherThan: "2.0.0.1"))
  ///
  public func isAppVersion(
    _ version: String,
    equalOrHigherThan minimalRequiredVersion: String
  ) throws -> Bool {
    let appVersionComponents = try versionComponents(from: version)
    let requiredVersionComponents = try versionComponents(from: minimalRequiredVersion)
    for (required, app) in zip(requiredVersionComponents, appVersionComponents) {
      if app > required { return true }
      if app < required { return false }
    }
    return appVersionComponents.count >= requiredVersionComponents.count
  }
}

private extension AppVersionValidator {
  func versionComponents(from string: String) throws -> [Int] {
    let collection = try string
      .components(separatedBy: ".")
      .map { try Int(throwable: $0) }
    guard !collection.isEmpty else { throw NSError(domain: "com.poviokit.version-validator", code: -4, userInfo: nil) }
    return collection
  }
}

fileprivate extension Int {
  init(throwable string: String) throws {
    guard let intValue = Int(string) else { throw NSError(domain: "com.poviokit.version-validator", code: -3, userInfo: nil) }
    self = intValue
  }
}
