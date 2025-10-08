//
//  ResultTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class ResultTests: XCTestCase {
  // MARK: - Success for Void
  
  func testSuccessWithoutParameter() {
    let result: Result<Void, Error> = .success()
    
    switch result {
    case .success:
      XCTAssertTrue(true, "Result should be success")
    case .failure:
      XCTFail("Result should not be failure")
    }
  }
  
  func testSuccessEquivalence() {
    let result1: Result<Void, Error> = .success()
    let result2: Result<Void, Error> = .success(())
    
    // Both should behave identically
    switch (result1, result2) {
    case (.success, .success):
      XCTAssertTrue(true, "Both results should be success")
    default:
      XCTFail("Both results should be success")
    }
  }
  
  func testSuccessInFunctionReturn() {
    func doSomething() -> Result<Void, Error> {
      // Simulate some operation that returns void
      return .success()
    }
    
    let result = doSomething()
    
    switch result {
    case .success:
      XCTAssertTrue(true, "Function should return success")
    case .failure(let error):
      XCTFail("Function should not fail: \(error)")
    }
  }
  
  func testSuccessInAsyncContext() async {
    func asyncOperation() async -> Result<Void, Error> {
      // Simulate async operation
      return .success()
    }
    
    let result = await asyncOperation()
    
    switch result {
    case .success:
      XCTAssertTrue(true, "Async operation should return success")
    case .failure(let error):
      XCTFail("Async operation should not fail: \(error)")
    }
  }
  
  enum TestError: Error {
    case testFailure
  }
  
  func testSuccessVsFailure() {
    func makeResult(isSuccess: Bool) -> Result<Void, TestError> {
      return isSuccess ? .success() : .failure(.testFailure)
    }

    let successResult = makeResult(isSuccess: true)
    let failureResult = makeResult(isSuccess: false)

    var successCalled = false
    var failureCalled = false

    switch successResult {
    case .success:
      successCalled = true
    case .failure:
      break
    }

    switch failureResult {
    case .success:
      break
    case .failure:
      failureCalled = true
    }

    XCTAssertTrue(successCalled, "Success result should trigger success case")
    XCTAssertTrue(failureCalled, "Failure result should trigger failure case")
  }
}
