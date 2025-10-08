//
//  StartupProcessServiceTests.swift
//  PovioKit_Tests
//
//  Created by Klemen Zagar on 05/12/2019.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class StartupProcessServiceTests: XCTestCase {
  func testShouldCompleteProccesWhenCallExecution() {
    let sut = StartupProcessService()
    let mock = MockedStartupService()
    sut.execute(process: mock)
    XCTAssertEqual(mock.completed, true)
  }
  
  func test_id_isUniqueForDifferentInstances() {
    let process1 = MockedStartupService()
    let process2 = MockedStartupService()
    
    XCTAssertNotEqual(process1.id, process2.id)
  }
}

private class MockedStartupService: StartupProcess {
  var completed: Bool = false
  func run(completion: @escaping (Bool) -> Void) {
    completed = true
    return
  }
}
