//
//  UserDefaultTests.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

class UserDefaultTests: XCTestCase {
  let userDefaults: UserDefaults = .standard
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    userDefaults.removeObject(forKey: Defaults.testBoolKey)
    userDefaults.removeObject(forKey: Defaults.testStringKey)
    userDefaults.removeObject(forKey: Defaults.testDataKey)
    userDefaults.removeObject(forKey: Defaults.testDataModelKey)
  }
  
  func testSaveStringValue() {
    // Given
    let givenValue = Defaults.testStringKey
    // When
    Defaults.screenName = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.screenName)
  }
  
  func testSaveBoolValue() {
    // Given
    let givenValue = true
    // When
    Defaults.isAuthenticated = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.isAuthenticated)
  }
  
  func testMigration() {
    var isAuth = UserDefaults.standard.bool(forKey: Defaults.testBoolKey)
    XCTAssertFalse(isAuth) // on first run this must be false
    
    UserDefaults.standard.set(true, forKey: Defaults.testBoolKey)
    isAuth = UserDefaults.standard.bool(forKey: Defaults.testBoolKey)
    XCTAssertTrue(isAuth) // not it should be true
    XCTAssertTrue(Defaults.isAuthenticated) // after migration value should also be true
  }

  func testResetValue() {
    // Given
    let givenValue = Defaults.testStringKey
    
    // Set an initial value
    Defaults.screenName = givenValue
    
    // When
    Defaults.$screenName.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.screenName, "default")
  }
  
  func testSaveDataValue() {
    // Given
    let givenValue: Data = .init()
    // When
    Defaults.profileData = givenValue
    // Then
    XCTAssertNotNil(Defaults.profileData)
  }
  
  func testSaveDataNullValue() {
    // Given
    let givenValue: Data? = nil
    // When
    Defaults.profileData = givenValue
    // Then
    XCTAssertNil(Defaults.profileData)
  }
  
  func testSaveCodable() {
    // Given
    let givenValue = TestDataModel(id: UUID().uuidString, number: 123)
    // When
    Defaults.dataModel = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.dataModel)
  }
  
  func testResetValueForCodable() {
    // Given
    let givenValue = TestDataModel(id: UUID().uuidString, number: 123)

    // Set an initial value
    Defaults.dataModel = givenValue
    
    // When
    Defaults.$dataModel.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.dataModel.id, "1")
    XCTAssertEqual(Defaults.dataModel.number, 1)
  }
}

extension UserDefaultTests {
  struct Defaults {
    static var testBoolKey = "test_bool_key"
    static var testStringKey = "test_string_key"
    static var testDataKey = "test_data_key"
    static var testDataModelKey = "test_data_model_key"
    
    @UserDefault(defaultValue: false, key: testBoolKey)
    static var isAuthenticated: Bool
    
    @UserDefault(defaultValue: "default", key: testStringKey)
    static var screenName: String
    
    @UserDefault(defaultValue: nil, key: testDataKey)
    static var profileData: Data?
    
    @UserDefault(defaultValue: TestDataModel(id: "1", number: 1), key: testDataModelKey)
    static var dataModel: TestDataModel
  }
  
  struct TestDataModel: Codable, Equatable {
    let id: String
    let number: Int
  }
}
