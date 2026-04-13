//
//  CollectionGroupedTests.swift
//  PovioKit_Tests
//
//  Created by Yll Fejziu on 14/11/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class CollectionGroupedTests: XCTestCase {
  func test_grouped_returnsEmptyDictionaryOnEmptyArray() {
    let sut: [Stub] = []
    XCTAssertEqual(sut.grouped { $0.createdAt }, [:])
  }
  
  func test_grouped_returnsGroupedDictionaryCorrectlyForSameDates() {
    let sut: [Stub] = [anyStub(), anyStub()]
    
    let grouped = sut.grouped { $0.createdAt }
    
    XCTAssertEqual(grouped.keys.count, 1)
    XCTAssertEqual(grouped.values.first?.count, 2)
  }
  
  func test_grouped_returnsGroupedDictionaryCorrectlyForDifferentDates() {
    let sut: [Stub] = [anyStub(), Stub(createdAt: currentDate())]
    
    let grouped = sut.grouped { $0.createdAt  }
    
    XCTAssertEqual(grouped.keys.count, 2)
    
    for value in grouped.values {
      XCTAssertEqual(value.count, 1)
    }
  }
}

// MARK: - Helpers
extension CollectionGroupedTests {
  class Stub {
    let id: String
    let createdAt: Date
    
    internal init(id: String = UUID().uuidString, createdAt: Date) {
      self.id = id
      self.createdAt = createdAt
    }
  }
  
  func anyStub() -> Stub {
    .init(createdAt: anyDate())
  }
  
  func anyDate() -> Date {
    .init(timeIntervalSince1970: 1662625349)
  }
  
  func currentDate() -> Date {
    .init()
  }
}

extension CollectionGroupedTests.Stub: Equatable {
  static func == (lhs: CollectionGroupedTests.Stub, rhs: CollectionGroupedTests.Stub) -> Bool {
    lhs.id == rhs.id
  }
}
