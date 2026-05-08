//
//  InAppPurchaseServiceTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitUtilities

final class InAppPurchaseServiceTests: XCTestCase {
  func testPurchasedProductIDsResolverFiltersUnknownIDs() {
    let resolved = PurchasedProductIDsResolver.resolve(
      entitlementProductIDs: ["pro.monthly", "unknown", "pro.yearly"],
      availableProductIDs: ["pro.monthly", "pro.yearly"]
    )
    
    XCTAssertEqual(resolved, ["pro.monthly", "pro.yearly"])
  }
  
  func testPurchasedProductIDsResolverDeduplicatesAndPreservesFirstSeenOrder() {
    let resolved = PurchasedProductIDsResolver.resolve(
      entitlementProductIDs: ["pro.yearly", "pro.monthly", "pro.yearly", "pro.monthly"],
      availableProductIDs: ["pro.monthly", "pro.yearly"]
    )
    
    XCTAssertEqual(resolved, ["pro.yearly", "pro.monthly"])
  }
}
