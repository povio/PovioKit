//
//  InAppPurchaseErrorTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class InAppPurchaseErrorTests: XCTestCase {
  
  // MARK: - Simple Error Cases
  
  func testMissingProductIdError() {
    let error = InAppPurchaseError.missingProductId
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testMissingReceiptError() {
    let error = InAppPurchaseError.missingReceipt
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testPaymentCancelledError() {
    let error = InAppPurchaseError.paymentCancelled
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testPaymentPendingError() {
    let error = InAppPurchaseError.paymentPending
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testNotPurchasedError() {
    let error = InAppPurchaseError.notPurchased
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testVerificationFailedError() {
    let error = InAppPurchaseError.verificationFailed
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  // MARK: - Associated Value Errors
  
  func testRestoreFailedError() {
    let underlyingError = NSError(domain: "TestDomain", code: 123, userInfo: nil)
    let error = InAppPurchaseError.restoreFailed(underlyingError)
    
    if case .restoreFailed(let wrappedError) = error {
      XCTAssertEqual((wrappedError as NSError).domain, "TestDomain")
      XCTAssertEqual((wrappedError as NSError).code, 123)
    } else {
      XCTFail("Should be restoreFailed with wrapped error")
    }
  }
  
  func testRequestFailedErrorWithError() {
    let underlyingError = NSError(domain: "RequestDomain", code: 456, userInfo: nil)
    let error = InAppPurchaseError.requestFailed(underlyingError)
    
    if case .requestFailed(let wrappedError) = error {
      XCTAssertNotNil(wrappedError)
      XCTAssertEqual((wrappedError as? NSError)?.domain, "RequestDomain")
      XCTAssertEqual((wrappedError as? NSError)?.code, 456)
    } else {
      XCTFail("Should be requestFailed with wrapped error")
    }
  }
  
  func testRequestFailedErrorWithNil() {
    let error = InAppPurchaseError.requestFailed(nil)
    
    if case .requestFailed(let wrappedError) = error {
      XCTAssertNil(wrappedError, "Should allow nil as associated value")
    } else {
      XCTFail("Should be requestFailed")
    }
  }
  
  func testValidationFailedError() {
    let underlyingError = NSError(domain: "ValidationDomain", code: 789, userInfo: nil)
    let error = InAppPurchaseError.validationFailed(underlyingError)
    
    if case .validationFailed(let wrappedError) = error {
      XCTAssertEqual((wrappedError as NSError).domain, "ValidationDomain")
      XCTAssertEqual((wrappedError as NSError).code, 789)
    } else {
      XCTFail("Should be validationFailed with wrapped error")
    }
  }
  
  // MARK: - Error Protocol Conformance
  
  func testConformsToError() {
    let error: Error = InAppPurchaseError.missingProductId
    
    XCTAssertNotNil(error, "InAppPurchaseError should conform to Error protocol")
  }
  
  func testCanBeThrownAndCaught() {
    func throwingFunction() throws {
      throw InAppPurchaseError.paymentCancelled
    }
    
    XCTAssertThrowsError(try throwingFunction()) { error in
      XCTAssertTrue(error is InAppPurchaseError, "Thrown error should be InAppPurchaseError type")
      if let iapError = error as? InAppPurchaseError {
        if case .paymentCancelled = iapError {
          // Success
        } else {
          XCTFail("Should be paymentCancelled case")
        }
      }
    }
  }
  
  func testCanThrowErrorWithAssociatedValue() {
    func throwingFunction() throws {
      let underlyingError = NSError(domain: "TestDomain", code: 100, userInfo: nil)
      throw InAppPurchaseError.restoreFailed(underlyingError)
    }
    
    do {
      try throwingFunction()
      XCTFail("Should throw error")
    } catch let InAppPurchaseError.restoreFailed(underlyingError) {
      XCTAssertEqual((underlyingError as NSError).domain, "TestDomain")
      XCTAssertEqual((underlyingError as NSError).code, 100)
    } catch {
      XCTFail("Should catch restoreFailed error")
    }
  }
  
  // MARK: - Switch Exhaustiveness
  
  func testAllCasesCanBeSwitched() {
    let testError = NSError(domain: "Test", code: 1, userInfo: nil)
    let errors: [InAppPurchaseError] = [
      .missingProductId,
      .missingReceipt,
      .paymentCancelled,
      .paymentPending,
      .notPurchased,
      .restoreFailed(testError),
      .requestFailed(testError),
      .validationFailed(testError),
      .verificationFailed
    ]
    
    for error in errors {
      var matched = false
      
      switch error {
      case .missingProductId:
        matched = true
      case .missingReceipt:
        matched = true
      case .paymentCancelled:
        matched = true
      case .paymentPending:
        matched = true
      case .notPurchased:
        matched = true
      case .restoreFailed:
        matched = true
      case .requestFailed:
        matched = true
      case .validationFailed:
        matched = true
      case .verificationFailed:
        matched = true
      }
      
      XCTAssertTrue(matched, "Error should be handled in switch")
    }
  }
  
  // MARK: - Pattern Matching
  
  func testPatternMatchingSimpleCases() {
    let error = InAppPurchaseError.missingProductId
    
    if case .missingProductId = error {
      XCTAssertTrue(true, "Pattern matching should work")
    } else {
      XCTFail("Pattern matching failed")
    }
  }
  
  func testPatternMatchingWithAssociatedValue() {
    let underlyingError = NSError(domain: "TestDomain", code: 200, userInfo: nil)
    let error = InAppPurchaseError.restoreFailed(underlyingError)
    
    if case .restoreFailed(let wrappedError) = error {
      XCTAssertEqual((wrappedError as NSError).code, 200)
    } else {
      XCTFail("Pattern matching with associated value failed")
    }
  }
  
  func testPatternMatchingIgnoringAssociatedValue() {
    let underlyingError = NSError(domain: "TestDomain", code: 300, userInfo: nil)
    let error = InAppPurchaseError.requestFailed(underlyingError)
    
    if case .requestFailed = error {
      XCTAssertTrue(true, "Pattern matching should work ignoring associated value")
    } else {
      XCTFail("Pattern matching failed")
    }
  }
  
  // MARK: - Result Type Integration
  
  func testResultTypeWithSimpleError() {
    let result: Result<String, InAppPurchaseError> = .failure(.missingReceipt)
    
    switch result {
    case .success:
      XCTFail("Should be failure")
    case .failure(let error):
      if case .missingReceipt = error {
        XCTAssertTrue(true)
      } else {
        XCTFail("Should be missingReceipt error")
      }
    }
  }
  
  func testResultTypeWithAssociatedValueError() {
    let underlyingError = NSError(domain: "Test", code: 1, userInfo: nil)
    let result: Result<Data, InAppPurchaseError> = .failure(.validationFailed(underlyingError))
    
    switch result {
    case .success:
      XCTFail("Should be failure")
    case .failure(let error):
      if case .validationFailed(let wrapped) = error {
        XCTAssertEqual((wrapped as NSError).code, 1)
      } else {
        XCTFail("Should be validationFailed error")
      }
    }
  }
  
  // MARK: - Error Handling Patterns
  
  func testOptionalErrorHandling() {
    func simulateOperation(shouldFail: Bool) -> InAppPurchaseError? {
      return shouldFail ? .paymentCancelled : nil
    }
    
    XCTAssertNil(simulateOperation(shouldFail: false))
    XCTAssertNotNil(simulateOperation(shouldFail: true))
  }
  
  func testErrorChaining() {
    let originalError = NSError(domain: "OriginalError", code: 999, userInfo: nil)
    let validationError = InAppPurchaseError.validationFailed(originalError)
    
    if case .validationFailed(let wrapped) = validationError {
      XCTAssertEqual((wrapped as NSError).domain, "OriginalError")
      XCTAssertEqual((wrapped as NSError).code, 999)
    } else {
      XCTFail("Should preserve error chain")
    }
  }
  
  // MARK: - Error Description
  
  func testErrorDescription() {
    let errors: [InAppPurchaseError] = [
      .missingProductId,
      .missingReceipt,
      .paymentCancelled,
      .verificationFailed
    ]
    
    for error in errors {
      let description = String(describing: error)
      XCTAssertFalse(description.isEmpty, "Error \(error) should have a description")
    }
  }
  
  func testErrorDescriptionWithAssociatedValue() {
    let underlyingError = NSError(domain: "Test", code: 123, userInfo: nil)
    let error = InAppPurchaseError.restoreFailed(underlyingError)
    let description = String(describing: error)
    
    XCTAssertFalse(description.isEmpty, "Error with associated value should have a description")
    XCTAssertTrue(description.contains("restoreFailed"), "Description should mention the error case")
  }
  
  // MARK: - Real-World Scenarios
  
  func testPurchaseFlowErrorHandling() {
    func simulatePurchaseFlow(step: Int) throws -> String {
      switch step {
      case 1:
        throw InAppPurchaseError.missingProductId
      case 2:
        throw InAppPurchaseError.paymentCancelled
      case 3:
        throw InAppPurchaseError.verificationFailed
      default:
        return "Success"
      }
    }
    
    XCTAssertThrowsError(try simulatePurchaseFlow(step: 1))
    XCTAssertThrowsError(try simulatePurchaseFlow(step: 2))
    XCTAssertThrowsError(try simulatePurchaseFlow(step: 3))
    XCTAssertNoThrow(try simulatePurchaseFlow(step: 4))
  }
  
  func testRestoreFlowErrorHandling() {
    let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
    let restoreError = InAppPurchaseError.restoreFailed(networkError)
    
    if case .restoreFailed(let error) = restoreError {
      let nsError = error as NSError
      XCTAssertEqual(nsError.domain, NSURLErrorDomain)
      XCTAssertEqual(nsError.code, NSURLErrorNotConnectedToInternet)
    } else {
      XCTFail("Should be restoreFailed error")
    }
  }
}

