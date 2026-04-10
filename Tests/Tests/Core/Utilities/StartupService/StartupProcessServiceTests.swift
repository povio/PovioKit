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
    let mock = MockedStartupProcess()
    sut.execute(process: mock)
    XCTAssertEqual(mock.completed, true)
  }
  
  func test_execute_returnsSameServiceInstance() {
    let sut = StartupProcessService()
    let returned = sut.execute(process: MockedStartupProcess())
    
    XCTAssertTrue(sut === returned)
  }
  
  func test_execute_callsCompletionPathForFailedProcess() {
    let sut = StartupProcessService()
    let mock = FailingStartupProcess()
    
    sut.execute(process: mock)
    
    XCTAssertTrue(mock.didRun)
    XCTAssertTrue(mock.didInvokeCompletion)
  }
  
  func test_id_isUniqueForDifferentInstances() {
    let process1 = MockedStartupProcess()
    let process2 = MockedStartupProcess()
    
    XCTAssertNotEqual(process1.id, process2.id)
  }
}

private class MockedStartupProcess: StartupProcess {
  var completed: Bool = false
  func run(completion: @escaping (Bool) -> Void) {
    completed = true
    completion(true)
  }
}

private class FailingStartupProcess: StartupProcess {
  var didRun = false
  var didInvokeCompletion = false
  
  func run(completion: @escaping (Bool) -> Void) {
    didRun = true
    completion(false)
    didInvokeCompletion = true
  }
}
