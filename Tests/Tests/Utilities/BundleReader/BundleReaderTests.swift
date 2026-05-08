//
//  BundleReaderTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 01/06/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class BundleReaderTests: XCTestCase {
  func test_init_doesNotMessageTheReader() {
    let (_, reader) = makeSUT()
    
    XCTAssertNil(reader.capturedRead)
  }
  
  func test_object_returnsExpectedValue() {
    let (sut, reader) = makeSUT()
    let key = "key"
    let value = "value"
    
    reader.replaceDictionaryWith([key: value])
    let fetchedValue = sut.object(forInfoDictionaryKey: "key") as? String
    let fetchedNilValue = sut.object(forInfoDictionaryKey: "anyKey")

    XCTAssertEqual(fetchedValue, value)
    XCTAssertNil(fetchedNilValue)
  }
}

// MARK: - Helpers
private extension BundleReaderTests {
  func makeSUT() -> (sut: BundleReader, reader: BundleSpy) {
    let reader = BundleSpy()
    let sut = BundleReader(bundle: reader)
    
    return (sut, reader)
  }
}

private class BundleSpy: Bundle, @unchecked Sendable {
  private(set) var capturedRead: String?
  private var internalDictionary: [String: String] = [:]
  override func object(forInfoDictionaryKey key: String) -> Any? {
    capturedRead = key
    
    return internalDictionary[key]
  }
  
  func replaceDictionaryWith(_ newDictionary: [String: String]) {
    internalDictionary = newDictionary
  }
}
