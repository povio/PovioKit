//
//  InAppPurchaseErrorTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitUtilities

final class InAppPurchaseErrorTests: XCTestCase {
  func test_simpleCases_areConstructibleAndDistinct() {
    let simple: [InAppPurchaseError] = [
      .missingProductId,
      .missingReceipt,
      .paymentCancelled,
      .paymentPending,
      .notPurchased,
      .verificationFailed
    ]
    
    XCTAssertEqual(simple.count, 6)
    
    if case .missingProductId = simple[0] {} else { XCTFail("Expected .missingProductId") }
    if case .missingReceipt = simple[1] {} else { XCTFail("Expected .missingReceipt") }
    if case .paymentCancelled = simple[2] {} else { XCTFail("Expected .paymentCancelled") }
    if case .paymentPending = simple[3] {} else { XCTFail("Expected .paymentPending") }
    if case .notPurchased = simple[4] {} else { XCTFail("Expected .notPurchased") }
    if case .verificationFailed = simple[5] {} else { XCTFail("Expected .verificationFailed") }
  }
  
  func test_restoreFailed_preservesAssociatedError() {
    let underlying = NSError(domain: "restore", code: 42)
    let error = InAppPurchaseError.restoreFailed(underlying)
    
    guard case .restoreFailed(let wrapped) = error else {
      XCTFail("Expected .restoreFailed, got \(error)")
      return
    }
    let ns = wrapped as NSError
    XCTAssertEqual(ns.domain, "restore")
    XCTAssertEqual(ns.code, 42)
  }
  
  func test_requestFailed_acceptsNilAndPreservesAssociatedError() {
    let nilCase = InAppPurchaseError.requestFailed(nil)
    guard case .requestFailed(let wrappedNil) = nilCase else {
      XCTFail("Expected .requestFailed, got \(nilCase)")
      return
    }
    XCTAssertNil(wrappedNil)
    
    let underlying = NSError(domain: "request", code: 7)
    let presentCase = InAppPurchaseError.requestFailed(underlying)
    guard case .requestFailed(let wrappedPresent) = presentCase else {
      XCTFail("Expected .requestFailed, got \(presentCase)")
      return
    }
    XCTAssertEqual((wrappedPresent as NSError?)?.code, 7)
  }
  
  func test_validationFailed_preservesAssociatedError() {
    let underlying = NSError(domain: "validate", code: 9)
    let error = InAppPurchaseError.validationFailed(underlying)
    
    guard case .validationFailed(let wrapped) = error else {
      XCTFail("Expected .validationFailed, got \(error)")
      return
    }
    XCTAssertEqual((wrapped as NSError).domain, "validate")
    XCTAssertEqual((wrapped as NSError).code, 9)
  }
  
  func test_errorConformance_allowsThrowCatchRoundTrip() throws {
    do {
      throw InAppPurchaseError.missingProductId
    } catch let error as InAppPurchaseError {
      if case .missingProductId = error {
        // OK
      } else {
        XCTFail("Caught wrong case: \(error)")
      }
    }
  }
}
