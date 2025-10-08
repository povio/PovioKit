//
//  ExifErrorTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class ExifErrorTests: XCTestCase {
  
  // MARK: - Error Cases
  
  func testCreateImageSourceError() {
    let error = ExifError.createImageSource
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testGetImagePropertiesError() {
    let error = ExifError.getImageProperties
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testGetImageTypeError() {
    let error = ExifError.getImageType
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testCreateImageDestinationError() {
    let error = ExifError.createImageDestination
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  func testCopyImageSourceError() {
    let error = ExifError.copyImageSource
    
    XCTAssertNotNil(error, "Error should be created")
  }
  
  // MARK: - Equatable
  
  func testErrorsAreEqual() {
    let error1 = ExifError.createImageSource
    let error2 = ExifError.createImageSource
    
    XCTAssertEqual(error1, error2, "Same error cases should be equal")
  }
  
  func testErrorsAreNotEqual() {
    let error1 = ExifError.createImageSource
    let error2 = ExifError.getImageProperties
    
    XCTAssertNotEqual(error1, error2, "Different error cases should not be equal")
  }
  
  func testAllErrorCasesAreDifferent() {
    let errors: [ExifError] = [
      .createImageSource,
      .getImageProperties,
      .getImageType,
      .createImageDestination,
      .copyImageSource
    ]
    
    for (index, error) in errors.enumerated() {
      for (otherIndex, otherError) in errors.enumerated() where index != otherIndex {
        XCTAssertNotEqual(error, otherError, "\(error) should not equal \(otherError)")
      }
    }
  }
  
  // MARK: - Error Protocol Conformance
  
  func testConformsToError() {
    let error: Error = ExifError.createImageSource
    
    XCTAssertNotNil(error, "ExifError should conform to Error protocol")
  }
  
  func testCanBeThrownAndCaught() {
    func throwingFunction() throws {
      throw ExifError.createImageSource
    }
    
    XCTAssertThrowsError(try throwingFunction()) { error in
      XCTAssertTrue(error is ExifError, "Thrown error should be ExifError type")
      XCTAssertEqual(error as? ExifError, .createImageSource, "Should catch the correct error")
    }
  }
  
  func testCanBeCaughtAsSpecificType() {
    do {
      throw ExifError.getImageProperties
    } catch let exifError as ExifError {
      XCTAssertEqual(exifError, .getImageProperties, "Should catch as ExifError")
    } catch {
      XCTFail("Should catch as ExifError type")
    }
  }
  
  // MARK: - Switch Exhaustiveness
  
  func testAllCasesCanBeSwitched() {
    let errors: [ExifError] = [
      .createImageSource,
      .getImageProperties,
      .getImageType,
      .createImageDestination,
      .copyImageSource
    ]
    
    for error in errors {
      var matched = false
      
      switch error {
      case .createImageSource:
        matched = true
      case .getImageProperties:
        matched = true
      case .getImageType:
        matched = true
      case .createImageDestination:
        matched = true
      case .copyImageSource:
        matched = true
      }
      
      XCTAssertTrue(matched, "Error \(error) should be handled in switch")
    }
  }
  
  // MARK: - Error Handling Patterns
  
  func testResultTypeWithError() {
    let result: Result<Data, ExifError> = .failure(.createImageSource)
    
    switch result {
    case .success:
      XCTFail("Should be failure")
    case .failure(let error):
      XCTAssertEqual(error, .createImageSource, "Should contain the correct error")
    }
  }
  
  func testOptionalErrorHandling() {
    func simulateOperation() -> ExifError? {
      return .getImageProperties
    }
    
    let error = simulateOperation()
    XCTAssertEqual(error, .getImageProperties, "Should return error")
  }
  
  // MARK: - Error Collection
  
  func testErrorsInArray() {
    let errors: [ExifError] = [
      .createImageSource,
      .getImageType,
      .copyImageSource
    ]
    
    XCTAssertEqual(errors.count, 3, "Should contain 3 errors")
    XCTAssertTrue(errors.contains(.createImageSource), "Should contain createImageSource")
    XCTAssertTrue(errors.contains(.getImageType), "Should contain getImageType")
    XCTAssertFalse(errors.contains(.getImageProperties), "Should not contain getImageProperties")
  }
  
  // MARK: - Hashable
  
  func testErrorsAreHashable() {
    let errorSet: Set<ExifError> = [
      .createImageSource,
      .createImageSource,
      .getImageProperties,
      .getImageType
    ]
    
    XCTAssertEqual(errorSet.count, 3, "Set should contain 3 unique errors")
    XCTAssertTrue(errorSet.contains(.createImageSource), "Set should contain createImageSource")
    XCTAssertTrue(errorSet.contains(.getImageProperties), "Set should contain getImageProperties")
    XCTAssertTrue(errorSet.contains(.getImageType), "Set should contain getImageType")
  }
  
  func testErrorsAsDictionaryKeys() {
    let errorMessages: [ExifError: String] = [
      .createImageSource: "Failed to create image source",
      .getImageProperties: "Failed to get properties",
      .createImageDestination: "Failed to create destination"
    ]
    
    XCTAssertEqual(errorMessages[.createImageSource], "Failed to create image source")
    XCTAssertEqual(errorMessages[.getImageProperties], "Failed to get properties")
    XCTAssertNil(errorMessages[.copyImageSource])
  }
  
  // MARK: - LocalizedError Support
  
  func testErrorDescription() {
    let error = ExifError.createImageSource as Error
    let description = String(describing: error)
    
    XCTAssertFalse(description.isEmpty, "Error should have a description")
    XCTAssertTrue(description.contains("createImageSource"), "Description should mention the error case")
  }
}

