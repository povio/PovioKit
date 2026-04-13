//
//  DataTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 10/11/2020.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest

class DataTests: XCTestCase {
  func testHexadecialString() {
    let data = "this is a text string".data(using: .utf8)
    XCTAssertEqual(data?.hexadecimalString, "746869732069732061207465787420737472696e67")
  }
  
  func testDecode() {
    let responseString = """
    {"id": 1, "name": "PovioKit"}
    """
    let data = responseString.data(using: .utf8)
    
    do {
      let object = try data?.decode(TestResponse.self, with: JSONDecoder())
      XCTAssertEqual(object?.id, 1)
      XCTAssertEqual(object?.name, "PovioKit")
    } catch {
      XCTFail("Could not decode TestResponse!")
    }
  }
  
  func test_decode_throwsErrorOnWrongResponse() {
    struct Sample: Decodable {
      let value: String
    }
    
    let responseData = "{\"value\": 5}".data(using: .utf8)!
    
    XCTAssertThrowsError(try responseData.decode(Sample.self, with: JSONDecoder()))
  }
}

private extension DataTests {
  struct TestResponse: Decodable {
    let id: Int
    let name: String
  }
}
