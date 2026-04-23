//
//  UserDefaultTests.swift
//  PovioKit
//
//  Created by Egzon Arifi on 25/01/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore
import PovioKitUtilities

// The whole suite runs on the main actor. That's consistent with how
// `XCTestCase` dispatches its test methods, and it lets the nested
// `Defaults` / `CustomDefaults` namespaces host `@UserDefault static var …`
// declarations under Swift 6 strict concurrency — the wrapped statics
// are main-actor isolated rather than nonisolated global mutable state.
@MainActor
class UserDefaultTests: XCTestCase {
  /// Suite-scoped storage so these tests never write into
  /// `UserDefaults.standard` (which would leak across runs and collide with
  /// a developer's own preferences on their machine).
  static let suiteName = "com.poviokit.tests.UserDefaultTests"
  static let userDefaults: UserDefaults = {
    let storage = UserDefaults(suiteName: suiteName)!
    storage.removePersistentDomain(forName: suiteName)
    return storage
  }()

  var userDefaults: UserDefaults { Self.userDefaults }

  override nonisolated func tearDownWithError() throws {
    try super.tearDownWithError()
    // `XCTestCase.tearDownWithError` is declared nonisolated on the
    // base class, so the override must stay nonisolated too. XCTest
    // drives `@MainActor` test classes' teardown on the main thread
    // in practice, so hopping back via `assumeIsolated` is sound.
    MainActor.assumeIsolated {
      Self.userDefaults.removePersistentDomain(forName: Self.suiteName)
      CustomDefaults.customStorage.removeObject(forKey: CustomDefaults.customKey)
    }
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
    var isAuth = userDefaults.bool(forKey: Defaults.testBoolKey)
    XCTAssertFalse(isAuth) // on first run this must be false

    userDefaults.set(true, forKey: Defaults.testBoolKey)
    isAuth = userDefaults.bool(forKey: Defaults.testBoolKey)
    XCTAssertTrue(isAuth) // now it should be true
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
  
  // MARK: - Additional Primitive Types Tests
  
  func testSaveIntValue() {
    // Given
    let givenValue = 42
    // When
    Defaults.userAge = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.userAge)
  }
  
  func testSaveDoubleValue() {
    // Given
    let givenValue = 3.14159
    // When
    Defaults.piValue = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.piValue, accuracy: 0.00001)
  }
  
  func testSaveFloatValue() {
    // Given
    let givenValue: Float = 2.71828
    // When
    Defaults.eulerNumber = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.eulerNumber, accuracy: 0.00001)
  }
  
  func testSaveDateValue() {
    // Given
    let givenValue = Date()
    // When
    Defaults.lastLoginDate = givenValue
    // Then
    XCTAssertEqual(givenValue.timeIntervalSince1970, Defaults.lastLoginDate.timeIntervalSince1970, accuracy: 0.001)
  }
  
  func testSaveUrlValue() {
    // Given
    let givenValue = URL(string: "https://example.com")!
    // When
    Defaults.apiBaseUrl = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.apiBaseUrl)
  }
  
  func testResetIntValue() {
    // Given
    Defaults.userAge = 99
    
    // When
    Defaults.$userAge.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.userAge, 0)
  }
  
  func testResetDoubleValue() {
    // Given
    Defaults.piValue = 99.99
    
    // When
    Defaults.$piValue.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.piValue, 0.0, accuracy: 0.00001)
  }
  
  func testResetFloatValue() {
    // Given
    Defaults.eulerNumber = 99.99
    
    // When
    Defaults.$eulerNumber.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.eulerNumber, 0.0, accuracy: 0.00001)
  }
  
  func testResetDateValue() {
    // Given
    Defaults.lastLoginDate = Date()
    let defaultDate = Date(timeIntervalSince1970: 0)
    
    // When
    Defaults.$lastLoginDate.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.lastLoginDate.timeIntervalSince1970, defaultDate.timeIntervalSince1970, accuracy: 0.001)
  }
  
  func testResetUrlValue() {
    // Given
    Defaults.apiBaseUrl = URL(string: "https://changed.com")!
    
    // When
    Defaults.$apiBaseUrl.resetValue()
    
    // Then
    XCTAssertEqual(Defaults.apiBaseUrl, URL(string: "https://default.com")!)
  }
  
  // MARK: - Optional Primitive Types Tests
  
  func testSaveOptionalIntValue() {
    // Given
    let givenValue: Int? = 123
    // When
    Defaults.optionalAge = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.optionalAge)
  }
  
  func testSaveOptionalIntNilValue() {
    // Given
    let givenValue: Int? = nil
    // When
    Defaults.optionalAge = givenValue
    // Then
    XCTAssertNil(Defaults.optionalAge)
  }
  
  func testSaveOptionalStringValue() {
    // Given
    let givenValue: String? = "Optional String"
    // When
    Defaults.optionalName = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.optionalName)
  }
  
  func testSaveOptionalStringNilValue() {
    // Given
    let givenValue: String? = nil
    // When
    Defaults.optionalName = givenValue
    // Then
    XCTAssertNil(Defaults.optionalName)
  }
  
  // MARK: - Collections Tests
  
  func testSaveArrayOfCodables() {
    // Given
    let givenValue = [
      TestDataModel(id: "1", number: 1),
      TestDataModel(id: "2", number: 2)
    ]
    // When
    Defaults.dataModelArray = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.dataModelArray)
  }
  
  func testSaveEmptyArray() {
    // Given
    let givenValue: [TestDataModel] = []
    // When
    Defaults.dataModelArray = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.dataModelArray)
    XCTAssertTrue(Defaults.dataModelArray.isEmpty)
  }
  
  func testSaveDictionary() {
    // Given
    let givenValue = ["key1": "value1", "key2": "value2"]
    // When
    Defaults.stringDictionary = givenValue
    // Then
    XCTAssertEqual(givenValue, Defaults.stringDictionary)
  }
  
  func testResetArrayValue() {
    // Given
    let givenValue = [
      TestDataModel(id: "10", number: 10),
      TestDataModel(id: "20", number: 20)
    ]
    Defaults.dataModelArray = givenValue
    
    // When
    Defaults.$dataModelArray.resetValue()
    
    // Then
    XCTAssertTrue(Defaults.dataModelArray.isEmpty)
  }
  
  // MARK: - Custom Storage Tests
  
  func testCustomUserDefaults() {
    let customDefaults = CustomDefaults.customStorage
    let givenValue = "Custom Storage Value"

    CustomDefaults.customValue = givenValue

    XCTAssertEqual(givenValue, CustomDefaults.customValue)
    XCTAssertEqual(givenValue, customDefaults.string(forKey: CustomDefaults.customKey))

    customDefaults.removeObject(forKey: CustomDefaults.customKey)
  }
  
  // MARK: - Custom Encoder/Decoder Tests
  
  func testCustomEncoderDecoder() {
    // Given
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    
    let testDate = Date()
    let givenValue = TestDataModelWithDate(id: "test", createdAt: testDate)
    
    // When
    CustomDefaults.dataWithDate = givenValue
    
    // Then
    XCTAssertEqual(givenValue.id, CustomDefaults.dataWithDate.id)
    XCTAssertEqual(givenValue.createdAt.timeIntervalSince1970, CustomDefaults.dataWithDate.createdAt.timeIntervalSince1970, accuracy: 1.0)
  }
  
  // MARK: - Migration Tests
  
  func testMigrationForBoolStoredAsJsonData() {
    // Given - simulate old format storage where Bool was JSON-encoded
    // This is the scenario: before update, Bool `true` was stored as JSON Data
    let boolValue = true
    if let encoded = try? JSONEncoder().encode(boolValue) {
      userDefaults.set(encoded, forKey: Defaults.testBoolKey)
    }
    
    // Verify it's stored as Data (not native Bool)
    XCTAssertNotNil(userDefaults.data(forKey: Defaults.testBoolKey))
    
    // When - read via UserDefault wrapper (should correctly decode JSON Data)
    let readValue = Defaults.isAuthenticated
    
    // Then - should return true, not false (the UserDefaults default for non-bool data)
    XCTAssertTrue(readValue, "Bool stored as JSON Data should be correctly migrated to true")
  }
  
  func testMigrationForIntStoredAsJsonData() {
    // Given - simulate old format storage where Int was JSON-encoded
    let intValue = 42
    if let encoded = try? JSONEncoder().encode(intValue) {
      userDefaults.set(encoded, forKey: Defaults.testIntKey)
    }
    
    // Verify it's stored as Data
    XCTAssertNotNil(userDefaults.data(forKey: Defaults.testIntKey))
    
    // When - read via UserDefault wrapper
    let readValue = Defaults.userAge
    
    // Then - should return 42, not 0
    XCTAssertEqual(readValue, 42, "Int stored as JSON Data should be correctly migrated")
  }
  
  func testMigrationForComplexType() {
    // Given - simulate old format storage (direct object storage)
    let oldValue = TestDataModel(id: "old-id", number: 999)
    
    // Manually encode and store as legacy format would have
    if let encoded = try? JSONEncoder().encode(oldValue) {
      userDefaults.set(encoded, forKey: Defaults.testComplexMigrationKey)
    }
    
    // When - read via UserDefault wrapper (should trigger migration)
    let readValue = Defaults.complexMigration
    
    // Then
    XCTAssertEqual(readValue.id, oldValue.id)
    XCTAssertEqual(readValue.number, oldValue.number)
    
    // Verify it was migrated to new format
    XCTAssertNotNil(userDefaults.data(forKey: Defaults.testComplexMigrationKey))
  }
  
  // MARK: - Notification Tests
  
  func testNotificationPostedOnValueChange() {
    // Given
    // Box the flag in a reference type so it can be mutated from the
    // `@Sendable` observer block without tripping strict concurrency.
    // `UserDefaults.didChangeNotification` is posted synchronously on
    // the thread that mutated the defaults, so no locking is needed.
    final class Flag: @unchecked Sendable { var value = false }
    let notificationReceived = Flag()
    
    let observer = NotificationCenter.default.addObserver(
      forName: UserDefaults.didChangeNotification,
      object: userDefaults,
      queue: nil
    ) { _ in
      notificationReceived.value = true
    }
    
    // When
    Defaults.screenName = "New Screen Name"
    
    // Then - notification should be posted synchronously
    XCTAssertTrue(notificationReceived.value, "UserDefaults.didChangeNotification should be posted")
    
    // Cleanup
    NotificationCenter.default.removeObserver(observer)
  }
  
  // MARK: - Projected Value Tests
  
  func testProjectedValueKey() {
    // Given & When
    let projectedValue = Defaults.$screenName
    
    // Then
    XCTAssertEqual(projectedValue.key, Defaults.testStringKey)
  }
  
  func testProjectedValueDefaultValue() {
    // Given & When
    let projectedValue = Defaults.$screenName
    
    // Then
    XCTAssertEqual(projectedValue.defaultValue, "default")
  }
  
  func testProjectedValueStorage() {
    // Given & When
    let projectedValue = Defaults.$screenName
    
    // Then
    XCTAssertEqual(projectedValue.storage, userDefaults)
  }
  
  // MARK: - Edge Cases Tests
  
  func testReadingCorruptedData() {
    // Given - store corrupted data
    let corruptedData = Data([0xFF, 0xFE, 0xFD])
    userDefaults.set(corruptedData, forKey: Defaults.testDataModelKey)
    
    // When - try to read via UserDefault
    let readValue = Defaults.dataModel
    
    // Then - should return default value
    XCTAssertEqual(readValue.id, "1")
    XCTAssertEqual(readValue.number, 1)
  }
  
  func testOverwritingExistingValue() {
    // Given
    let firstValue = "First Value"
    let secondValue = "Second Value"
    
    // When
    Defaults.screenName = firstValue
    XCTAssertEqual(Defaults.screenName, firstValue)
    
    Defaults.screenName = secondValue
    
    // Then
    XCTAssertEqual(Defaults.screenName, secondValue)
  }
  
  func testPrimitiveTypeReturnsFalseForBool() {
    // Given
    Defaults.isAuthenticated = false
    
    // When
    let value = Defaults.isAuthenticated
    
    // Then - should correctly handle false boolean
    XCTAssertFalse(value)
  }
  
  func testReadingZeroIntValue() {
    // Given
    Defaults.userAge = 0
    
    // When
    let value = Defaults.userAge
    
    // Then - should correctly return 0, not default value
    XCTAssertEqual(value, 0)
  }
  
  // MARK: - Default Value Tests (Missing Key)
  
  func testBoolMissingKeyReturnsDefaultValue() {
    // Given - key doesn't exist (cleaned up in tearDown)
    // Default value is true (different from UserDefaults' false)
    
    // When
    let value = Defaults.enabledFeature
    
    // Then - should return custom defaultValue (true), not UserDefaults default (false)
    XCTAssertTrue(value)
  }
  
  func testIntMissingKeyReturnsDefaultValue() {
    // Given - key doesn't exist (cleaned up in tearDown)
    // Default value is 42 (different from UserDefaults' 0)
    
    // When
    let value = Defaults.defaultScore
    
    // Then - should return custom defaultValue (42), not UserDefaults default (0)
    XCTAssertEqual(value, 42)
  }
  
  func testDoubleMissingKeyReturnsDefaultValue() {
    // Given - key doesn't exist (cleaned up in tearDown)
    // Default value is 3.14 (different from UserDefaults' 0.0)
    
    // When
    let value = Defaults.defaultPi
    
    // Then - should return custom defaultValue (3.14), not UserDefaults default (0.0)
    XCTAssertEqual(value, 3.14, accuracy: 0.001)
  }
  
  func testFloatMissingKeyReturnsDefaultValue() {
    // Given - key doesn't exist (cleaned up in tearDown)
    // Default value is 2.71 (different from UserDefaults' 0.0)
    
    // When
    let value = Defaults.defaultEuler
    
    // Then - should return custom defaultValue (2.71), not UserDefaults default (0.0)
    XCTAssertEqual(value, 2.71, accuracy: 0.001)
  }
}

extension UserDefaultTests {
  @MainActor
  struct Defaults {
    static let testBoolKey = "test_bool_key"
    static let testStringKey = "test_string_key"
    static let testDataKey = "test_data_key"
    static let testDataModelKey = "test_data_model_key"
    static let testIntKey = "test_int_key"
    static let testDoubleKey = "test_double_key"
    static let testFloatKey = "test_float_key"
    static let testDateKey = "test_date_key"
    static let testUrlKey = "test_url_key"
    static let testOptionalIntKey = "test_optional_int_key"
    static let testOptionalStringKey = "test_optional_string_key"
    static let testArrayKey = "test_array_key"
    static let testDictionaryKey = "test_dictionary_key"
    static let testComplexMigrationKey = "test_complex_migration_key"
    static let testEnabledFeatureKey = "test_enabled_feature_key"
    static let testDefaultScoreKey = "test_default_score_key"
    static let testDefaultPiKey = "test_default_pi_key"
    static let testDefaultEulerKey = "test_default_euler_key"

    /// All wrappers in this struct go through the isolated test suite so the
    /// tests are safe to run in parallel with other suites and never touch
    /// `UserDefaults.standard`.
    static let storage = UserDefaultTests.userDefaults

    @UserDefault(defaultValue: false, key: testBoolKey, storage: storage)
    static var isAuthenticated: Bool

    @UserDefault(defaultValue: "default", key: testStringKey, storage: storage)
    static var screenName: String

    @UserDefault(defaultValue: nil, key: testDataKey, storage: storage)
    static var profileData: Data?

    @UserDefault(defaultValue: TestDataModel(id: "1", number: 1), key: testDataModelKey, storage: storage)
    static var dataModel: TestDataModel

    @UserDefault(defaultValue: 0, key: testIntKey, storage: storage)
    static var userAge: Int

    @UserDefault(defaultValue: 0.0, key: testDoubleKey, storage: storage)
    static var piValue: Double

    @UserDefault(defaultValue: 0.0, key: testFloatKey, storage: storage)
    static var eulerNumber: Float

    @UserDefault(defaultValue: Date(timeIntervalSince1970: 0), key: testDateKey, storage: storage)
    static var lastLoginDate: Date

    @UserDefault(defaultValue: URL(string: "https://default.com")!, key: testUrlKey, storage: storage)
    static var apiBaseUrl: URL

    @UserDefault(defaultValue: nil, key: testOptionalIntKey, storage: storage)
    static var optionalAge: Int?

    @UserDefault(defaultValue: nil, key: testOptionalStringKey, storage: storage)
    static var optionalName: String?

    @UserDefault(defaultValue: [], key: testArrayKey, storage: storage)
    static var dataModelArray: [TestDataModel]

    @UserDefault(defaultValue: [:], key: testDictionaryKey, storage: storage)
    static var stringDictionary: [String: String]

    @UserDefault(defaultValue: TestDataModel(id: "default", number: 0), key: testComplexMigrationKey, storage: storage)
    static var complexMigration: TestDataModel

    @UserDefault(defaultValue: true, key: testEnabledFeatureKey, storage: storage)
    static var enabledFeature: Bool

    @UserDefault(defaultValue: 42, key: testDefaultScoreKey, storage: storage)
    static var defaultScore: Int

    @UserDefault(defaultValue: 3.14, key: testDefaultPiKey, storage: storage)
    static var defaultPi: Double

    @UserDefault(defaultValue: 2.71, key: testDefaultEulerKey, storage: storage)
    static var defaultEuler: Float
  }
  
  @MainActor
  struct CustomDefaults {
    static let customKey = "custom_test_key"
    // Use the same isolated suite as the main test case so nothing spills
    // into other suites, but keep a distinct reference to mirror how a real
    // consumer would pass a custom `storage`.
    static let customStorage = UserDefaults(
      suiteName: "com.poviokit.tests.UserDefaultTests.custom"
    )!
    
    @UserDefault(defaultValue: "default", key: customKey, storage: customStorage)
    static var customValue: String
    
    static let customEncoder: JSONEncoder = {
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      return encoder
    }()
    
    static let customDecoder: JSONDecoder = {
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      return decoder
    }()
    
    @UserDefault(
      defaultValue: TestDataModelWithDate(id: "default", createdAt: Date(timeIntervalSince1970: 0)),
      key: "test_data_with_date_key",
      storage: customStorage,
      encoder: customEncoder,
      decoder: customDecoder
    )
    static var dataWithDate: TestDataModelWithDate
  }
  
  struct TestDataModel: Codable, Equatable {
    let id: String
    let number: Int
  }
  
  struct TestDataModelWithDate: Codable, Equatable {
    let id: String
    let createdAt: Date
  }
}
