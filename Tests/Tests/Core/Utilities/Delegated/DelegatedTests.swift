//
//  DelegatedTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitUtilities

final class DelegatedTests: XCTestCase {
  
  // MARK: - Test Objects
  
  class TestObject {
    var callCount = 0
    var lastInput: String?
    
    func handleString(_ input: String) -> String {
      callCount += 1
      lastInput = input
      return "Handled: \(input)"
    }
    
    func handleInt(_ input: Int) -> Int {
      callCount += 1
      return input * 2
    }
    
    func handleVoid() {
      callCount += 1
    }
    
    func handleVoidWithReturn() -> String {
      callCount += 1
      return "Called"
    }
  }
  
  // MARK: - Input/Output Tests
  
  func testDelegatedWithInputAndOutput() {
    var delegated = Delegated<String, String>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object, input in
      object?.handleString(input) ?? ""
    }
    
    let result = delegated("test")
    
    XCTAssertEqual(result, "Handled: test", "Should return handled string")
    XCTAssertEqual(testObject.callCount, 1, "Should call delegate once")
    XCTAssertEqual(testObject.lastInput, "test", "Should receive correct input")
  }
  
  func testDelegatedWithIntegerTypes() {
    var delegated = Delegated<Int, Int>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object, input in
      object?.handleInt(input) ?? 0
    }
    
    let result = delegated(5)
    
    XCTAssertEqual(result, 10, "Should return doubled value")
    XCTAssertEqual(testObject.callCount, 1, "Should call delegate once")
  }
  
  func testDelegatedMultipleCalls() {
    var delegated = Delegated<String, String>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object, input in
      object?.handleString(input) ?? ""
    }
    
    _ = delegated("first")
    _ = delegated("second")
    _ = delegated("third")
    
    XCTAssertEqual(testObject.callCount, 3, "Should call delegate three times")
    XCTAssertEqual(testObject.lastInput, "third", "Should have last input")
  }
  
  // MARK: - Void Input Tests
  
  func testDelegatedWithVoidInputAndOutput() {
    var delegated = Delegated<Void, String>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object in
      object?.handleVoidWithReturn() ?? ""
    }
    
    let result = delegated()
    
    XCTAssertEqual(result, "Called", "Should return value from void input")
    XCTAssertEqual(testObject.callCount, 1, "Should call delegate once")
  }
  
  // MARK: - Void Output Tests
  
  func testDelegatedWithInputAndVoidOutput() {
    var delegated = Delegated<String, Void>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object, input in
      object?.lastInput = input
    }
    
    delegated("void test")
    
    XCTAssertEqual(testObject.lastInput, "void test", "Should receive input with void output")
  }
  
  // MARK: - VoidDelegate (Void/Void) Tests
  
  func testVoidDelegate() {
    var delegated: VoidDelegate = Delegated<Void, Void>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object in
      object?.handleVoid()
    }
    
    delegated()
    
    XCTAssertEqual(testObject.callCount, 1, "VoidDelegate should call delegate")
  }
  
  func testVoidDelegateMultipleCalls() {
    var delegated: VoidDelegate = Delegated<Void, Void>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object in
      object?.handleVoid()
    }
    
    delegated()
    delegated()
    delegated()
    
    XCTAssertEqual(testObject.callCount, 3, "VoidDelegate should support multiple calls")
  }
  
  // MARK: - Weak Reference Tests
  
  func testWeakReferenceBehavior() {
    var delegated = Delegated<String, String>()
    var testObject: TestObject? = TestObject()
    
    delegated.delegate(to: testObject!) { object, input in
      object?.handleString(input) ?? "nil"
    }
    
    // Object exists
    let result1 = delegated("before release")
    XCTAssertEqual(result1, "Handled: before release", "Should work while object exists")
    
    // Release the object
    testObject = nil
    
    // Object is deallocated
    let result2 = delegated("after release")
    XCTAssertEqual(result2, "nil", "Should return default value when object is deallocated")
  }
  
  func testWeakReferenceWithVoidDelegate() {
    var delegated: VoidDelegate = Delegated<Void, Void>()
    var testObject: TestObject? = TestObject()
    var callCount = 0
    
    delegated.delegate(to: testObject!) { object in
      if object != nil {
        callCount += 1
      }
    }
    
    // Object exists
    delegated()
    XCTAssertEqual(callCount, 1, "Should call while object exists")
    
    // Release the object
    testObject = nil
    
    // Object is deallocated - callback still fires but with nil object
    delegated()
    XCTAssertEqual(callCount, 1, "Should not increment when object is nil")
  }
  
  // MARK: - Reassignment Tests
  
  func testDelegateReassignment() {
    var delegated = Delegated<String, String>()
    let testObject1 = TestObject()
    let testObject2 = TestObject()
    
    // First delegation
    delegated.delegate(to: testObject1) { object, input in
      object?.handleString(input) ?? ""
    }
    
    _ = delegated("first")
    XCTAssertEqual(testObject1.callCount, 1, "First object should be called")
    XCTAssertEqual(testObject2.callCount, 0, "Second object should not be called")
    
    // Reassign to second object
    delegated.delegate(to: testObject2) { object, input in
      object?.handleString(input) ?? ""
    }
    
    _ = delegated("second")
    XCTAssertEqual(testObject1.callCount, 1, "First object should not be called again")
    XCTAssertEqual(testObject2.callCount, 1, "Second object should be called")
  }
  
  // MARK: - Complex Types Tests
  
  func testDelegatedWithComplexTypes() {
    struct ComplexInput {
      let name: String
      let value: Int
    }
    
    struct ComplexOutput {
      let result: String
    }
    
    var delegated = Delegated<ComplexInput, ComplexOutput>()
    let testObject = TestObject()
    
    delegated.delegate(to: testObject) { object, input in
      object?.callCount += 1
      return ComplexOutput(result: "\(input.name): \(input.value)")
    }
    
    let input = ComplexInput(name: "test", value: 42)
    let output = delegated(input)
    
    XCTAssertEqual(output.result, "test: 42", "Should handle complex types")
    XCTAssertEqual(testObject.callCount, 1, "Should call delegate with complex types")
  }
}

