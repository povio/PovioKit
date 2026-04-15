//
//  DecodableDictionaryTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 11/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

class DecodableDictionaryTests: XCTestCase {
  func testDecode() {
    let responseString = """
    {"id": 12, "configuration": {"name": "PovioKit", "value": 4, "values": [1,2,3]}}
    """
    let data = responseString.data(using: .utf8)
    do {
      let object = try data?.decode(TestResponse.self, with: JSONDecoder())
      XCTAssertEqual(object?.id, 12)
      XCTAssertEqual(object?.configuration.dictionary["name"] as? String, "PovioKit")
      XCTAssertEqual(object?.configuration.dictionary["value"] as? Int, 4)
      XCTAssertEqual((object?.configuration.dictionary["values"] as? [Int])?.count, 3)
    } catch {
      XCTFail("Could not decode TestResponse! \(error)")
    }
  }
  
  func testDecodeThrowsWhenConfigurationIsNotDictionary() {
    let responseString = """
    {"id": 12, "configuration": [1,2,3]}
    """
    let data = responseString.data(using: .utf8)
    
    XCTAssertThrowsError(try data?.decode(TestResponse.self, with: JSONDecoder()))
  }
}

private extension DecodableDictionaryTests {
  struct TestResponse: Decodable {
    let id: Int
    let configuration: DecodableDictionary
  }
}
