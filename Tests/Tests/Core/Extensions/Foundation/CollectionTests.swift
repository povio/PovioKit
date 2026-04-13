//
//  CollectionTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 05/05/2019.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class CollectionTests: XCTestCase {
  func testSafeSubscript() {
    let array = [1, 2]
    XCTAssertEqual(array[safe: 0], 1)
    XCTAssertEqual(array[safe: 1], 2)
    XCTAssertNil(array[safe: 2])
  }
  
  func testConditionalCount() {
    let array: [Any] = ["one", "two", 3, 4]
    XCTAssertEqual(array.count(where: { $0 is String}), 2)
    XCTAssertEqual(array.count(where: { $0 is Int}), 2)
  }
  
  func testMutateEach1() {
    var array = [1, 2, 3, 4, 5]
    array.mutateEach { $0 *= 2 }
    XCTAssertEqual(array, [2, 4, 6, 8, 10])
  }
  
  func testMutateEach2() {
    struct A: Equatable {
      var x = true
      
      mutating func mutate() {
        x.toggle()
      }
    }
    var array = [A](repeating: .init(), count: 5)
    array.mutateEach { $0.mutate() }
    XCTAssertEqual(array, .init(repeating: .init(x: false), count: 5))
  }
}
