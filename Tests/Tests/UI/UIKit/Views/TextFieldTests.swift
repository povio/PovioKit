//
//  TextFieldTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUIKit

@MainActor
final class TextFieldTests: XCTestCase {
  func test_isValid_whenNoRuleIsSet_alwaysReturnsTrue() {
    let field = TextField()
    
    XCTAssertTrue(field.isValid)
    field.text = "anything"
    XCTAssertTrue(field.isValid)
  }
  
  func test_isValid_whenRulePasses_returnsTrueAndForwardsText() {
    let rule = RecordingRule(result: true, error: "required")
    let field = TextField(with: rule)
    field.text = "hello"
    
    XCTAssertTrue(field.isValid)
    XCTAssertEqual(rule.receivedInputs, ["hello"])
  }
  
  func test_isValid_whenRuleFails_returnsFalseAndForwardsText() {
    let rule = RecordingRule(result: false, error: "required")
    let field = TextField(with: rule)
    field.text = "oops"
    
    XCTAssertFalse(field.isValid)
    XCTAssertEqual(rule.receivedInputs, ["oops"])
  }
  
  func test_isValid_whenCalledRepeatedly_forwardsLatestText() {
    let rule = RecordingRule(result: true, error: "required")
    let field = TextField(with: rule)
    
    field.text = "first"
    _ = field.isValid
    field.text = "second"
    _ = field.isValid
    
    XCTAssertEqual(rule.receivedInputs, ["first", "second"])
  }
  
  func test_setRule_replacesInitialRule() {
    let failing = RecordingRule(result: false, error: "failing")
    let passing = RecordingRule(result: true, error: "passing")
    let field = TextField(with: failing)
    field.text = "value"
    
    XCTAssertFalse(field.isValid)
    
    field.setRule(passing)
    XCTAssertTrue(field.isValid)
    XCTAssertEqual(passing.receivedInputs, ["value"])
  }
  
  func test_text_getterReturnsValueSetThroughSetter() {
    let field = TextField()
    field.text = "Hello"
    XCTAssertEqual(field.text, "Hello")
  }
}

private final class RecordingRule: RuleValidatable {
  let error: String
  private let result: Bool
  private(set) var receivedInputs: [String?] = []
  
  init(result: Bool, error: String) {
    self.result = result
    self.error = error
  }
  
  func validate(_ input: String?) -> Bool {
    receivedInputs.append(input)
    return result
  }
}

#endif
