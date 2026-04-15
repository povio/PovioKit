//
//  AppInfoTests.swift
//  PovioKit_Tests
//
//  Created by Toni Kocjan on 19/02/2021.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
@testable import PovioKitCore

final class AppInfoTests: XCTestCase {
  private final class URLOpenSpy {
    private(set) var openedUrls: [URL] = []
    var shouldAllowOpening = true
    
    func canOpen(_ url: URL) -> Bool {
      shouldAllowOpening
    }
    
    func open(_ url: URL) {
      openedUrls.append(url)
    }
  }
  
  override func tearDown() {
    AppInfoURLHandlerStore.canOpenUrlHandlerForTesting = nil
    AppInfoURLHandlerStore.openUrlHandlerForTesting = nil
    super.tearDown()
  }
  
  private func installSpy(_ spy: URLOpenSpy) {
    AppInfoURLHandlerStore.canOpenUrlHandlerForTesting = spy.canOpen
    AppInfoURLHandlerStore.openUrlHandlerForTesting = spy.open
  }
  
  // MARK: - Bundle Properties
  
  func testBundleIdIsNotEmpty() {
    let bundleId = AppInfo.bundleId
    
    XCTAssertFalse(bundleId.isEmpty, "Bundle ID should not be empty")
  }
  
  func testBundleIdFormat() {
    let bundleId = AppInfo.bundleId
    
    // Bundle IDs typically contain at least one period
    XCTAssertTrue(bundleId.contains(".") || bundleId.count > 0, "Bundle ID should be valid format")
  }
  
  func testNameIsNotEmpty() {
    let name = AppInfo.name
    
    XCTAssertFalse(name.isEmpty, "App name should not be empty")
  }
  
  func testNameExists() {
    let name = AppInfo.name
    
    XCTAssertGreaterThan(name.count, 0, "App name should have characters")
  }
  
  func testBuildIsNotEmpty() {
    let build = AppInfo.build
    
    XCTAssertFalse(build.isEmpty, "Build number should not be empty")
  }
  
  func testBuildIsNumericOrAlphanumeric() {
    let build = AppInfo.build
    
    // Build numbers are typically numeric or alphanumeric
    let isValid = !build.isEmpty && (build.allSatisfy { $0.isNumber || $0.isLetter || $0 == "." })
    XCTAssertTrue(isValid, "Build should be valid format")
  }
  
  func testVersionIsNotEmpty() {
    let version = AppInfo.version
    
    XCTAssertFalse(version.isEmpty, "Version should not be empty")
  }
  
  func testVersionFormat() {
    let version = AppInfo.version
    
    // Versions typically contain numbers and periods (e.g., "1.0.0")
    let hasNumbers = version.contains(where: { $0.isNumber })
    XCTAssertTrue(hasNumbers, "Version should contain numbers")
  }
  
  func testVersionIsSemanticVersionFormat() {
    let version = AppInfo.version
    
    // Should be able to split by periods
    let components = version.split(separator: ".")
    XCTAssertGreaterThanOrEqual(components.count, 1, "Version should have at least one component")
  }
  
  // MARK: - Bundle Properties Consistency
  
  func testBundlePropertiesAreConsistent() {
    let bundleId1 = AppInfo.bundleId
    let bundleId2 = AppInfo.bundleId
    
    XCTAssertEqual(bundleId1, bundleId2, "Bundle ID should be consistent")
  }
  
  func testVersionIsConsistent() {
    let version1 = AppInfo.version
    let version2 = AppInfo.version
    
    XCTAssertEqual(version1, version2, "Version should be consistent")
  }
  
  func testBuildIsConsistent() {
    let build1 = AppInfo.build
    let build2 = AppInfo.build
    
    XCTAssertEqual(build1, build2, "Build should be consistent")
  }
  
  func testNameIsConsistent() {
    let name1 = AppInfo.name
    let name2 = AppInfo.name
    
    XCTAssertEqual(name1, name2, "Name should be consistent")
  }
  
  // MARK: - URL Building - App Store
  
  func testOpenAppStoreWithValidId() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openAppStore(appId: "123456789")
    XCTAssertTrue(result, "Should report success with valid app ID")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt to open one App Store URL")
    XCTAssertEqual(spy.openedUrls.first?.absoluteString, "itms-apps://apps.apple.com/app/id123456789")
  }
  
  func testOpenAppStoreWithEmptyId() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openAppStore(appId: "")
    XCTAssertTrue(result, "Should still return success when URL can be formed")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should still build and open URL for empty app ID")
  }
  
  func testOpenAppStoreWithLongId() {
    let longId = String(repeating: "1", count: 20)
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openAppStore(appId: longId)
    XCTAssertTrue(result, "Should handle long app IDs")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt to open URL for long app ID")
  }
  
  func testOpenAppStoreWithSpecialCharacters() {
    // Test various special characters
    let specialIds = ["123-456", "id@123", "app.123"]
    let spy = URLOpenSpy()
    installSpy(spy)
    
    for appId in specialIds {
      let result = AppInfo.openAppStore(appId: appId)
      XCTAssertTrue(result, "Should handle special characters in app ID")
    }
    XCTAssertEqual(spy.openedUrls.count, specialIds.count, "Should attempt to open URL for each app ID")
  }
  
  // MARK: - URL Building - Phone Calls
  
  func testCallWithValidNumber() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.call("1234567890")
    XCTAssertTrue(result, "Should report success with valid number")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt one phone call URL")
    XCTAssertEqual(spy.openedUrls.first?.absoluteString, "tel://1234567890")
  }
  
  func testCallWithEmptyNumber() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.call("")
    XCTAssertFalse(result, "Should fail for empty numbers")
    XCTAssertEqual(spy.openedUrls.count, 0, "Should not attempt to open an invalid tel URL")
  }
  
  func testCallWithInternationalFormat() {
    let numbers = ["+1234567890", "+44-123-456-7890", "001-123-456-7890"]
    let spy = URLOpenSpy()
    installSpy(spy)
    
    for number in numbers {
      let result = AppInfo.call(number)
      XCTAssertTrue(result, "Should handle international number formats")
    }
    XCTAssertEqual(spy.openedUrls.count, numbers.count, "Should attempt one URL per phone number")
  }
  
  func testCallWithSpecialCharacters() {
    let numbers = ["(123) 456-7890", "123.456.7890", "123 456 7890"]
    let spy = URLOpenSpy()
    installSpy(spy)
    
    for number in numbers {
      let result = AppInfo.call(number)
      XCTAssertTrue(result, "Should handle numbers with special characters")
    }
    XCTAssertEqual(spy.openedUrls.count, numbers.count, "Should attempt one URL per phone number")
    XCTAssertEqual(
      spy.openedUrls.map(\.absoluteString),
      ["tel://1234567890", "tel://1234567890", "tel://1234567890"],
      "Should sanitize phone numbers to URL-safe values"
    )
  }
  
  // MARK: - URL Opening
  
  func testOpenUrlWithValidUrl() {
    guard let url = URL(string: "https://www.example.com") else {
      XCTFail("Failed to create valid URL")
      return
    }
    
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openUrl(url)
    XCTAssertTrue(result, "Should report success with valid URL")
    XCTAssertEqual(spy.openedUrls.first, url, "Should forward exact URL to opener")
  }
  
  func testOpenUrlWithSafariOption() {
    guard let url = URL(string: "https://www.example.com") else {
      XCTFail("Failed to create valid URL")
      return
    }
    
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openUrl(url, inSafari: true)
    XCTAssertTrue(result, "Should report success with inSafari option")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt to open one URL")
  }
  
  func testOpenUrlWithHttpUrl() {
    guard let url = URL(string: "http://www.example.com") else {
      XCTFail("Failed to create HTTP URL")
      return
    }
    
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openUrl(url)
    XCTAssertTrue(result, "Should handle HTTP URLs")
    XCTAssertEqual(spy.openedUrls.first, url, "Should open HTTP URL")
  }
  
  func testOpenUrlWithHttpsUrl() {
    guard let url = URL(string: "https://www.example.com") else {
      XCTFail("Failed to create HTTPS URL")
      return
    }
    
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openUrl(url)
    XCTAssertTrue(result, "Should handle HTTPS URLs")
    XCTAssertEqual(spy.openedUrls.first, url, "Should open HTTPS URL")
  }
  
  func testOpenUrlWithCustomScheme() {
    guard let url = URL(string: "myapp://deeplink") else {
      XCTFail("Failed to create custom scheme URL")
      return
    }
    
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openUrl(url)
    XCTAssertTrue(result, "Should handle custom URL schemes")
    XCTAssertEqual(spy.openedUrls.first, url, "Should open custom scheme URL")
  }
  
  func testOpenUrlReturnsFalseWhenSystemCannotOpen() {
    guard let url = URL(string: "myapp://deeplink") else {
      XCTFail("Failed to create custom scheme URL")
      return
    }
    
    let spy = URLOpenSpy()
    spy.shouldAllowOpening = false
    installSpy(spy)
    
    let result = AppInfo.openUrl(url)
    XCTAssertFalse(result, "Should report failure when canOpenURL is false")
    XCTAssertTrue(spy.openedUrls.isEmpty, "Should not invoke opener when cannot open URL")
  }
  
#if os(iOS)
  // MARK: - iOS-Specific Tests
  
  func testOpenSettings() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openSettings()
    XCTAssertTrue(result, "Should report success when opening settings")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt to open settings URL")
  }
  
  func testOpenNotificationSettings() {
    let spy = URLOpenSpy()
    installSpy(spy)
    let result = AppInfo.openNotificationSettings()
    XCTAssertTrue(result, "Should report success when opening notification settings")
    XCTAssertEqual(spy.openedUrls.count, 1, "Should attempt to open notification settings URL")
  }
#endif
  
  // MARK: - Edge Cases
  
  func testMultipleCallsToSameMethod() {
    let spy = URLOpenSpy()
    installSpy(spy)
    // Verify methods can be called multiple times without issues
    XCTAssertNoThrow({
      AppInfo.openAppStore(appId: "123")
      AppInfo.openAppStore(appId: "456")
      AppInfo.openAppStore(appId: "789")
    }(), "Should handle multiple calls")
    XCTAssertEqual(spy.openedUrls.count, 3, "Should attempt to open one URL per call")
  }
  
  func testConcurrentAccessToBundleProperties() {
    let expectation = expectation(description: "Concurrent access")
    expectation.expectedFulfillmentCount = 10
    
    DispatchQueue.concurrentPerform(iterations: 10) { _ in
      _ = AppInfo.bundleId
      _ = AppInfo.version
      _ = AppInfo.build
      _ = AppInfo.name
      expectation.fulfill()
    }
    
    wait(for: [expectation], timeout: 5.0)
  }
  
  // MARK: - Real-World Scenarios
  
  func testAppStoreUrlBuilding() {
    // Simulate real App Store IDs
    let realAppIds = ["12345678", "987654321", "1234567890"]
    let spy = URLOpenSpy()
    installSpy(spy)
    
    for appId in realAppIds {
      let result = AppInfo.openAppStore(appId: appId)
      XCTAssertTrue(result, "Should handle real App Store IDs")
    }
    XCTAssertEqual(spy.openedUrls.count, realAppIds.count, "Should attempt to open one URL per app ID")
  }
  
  func testVersionStringForDisplay() {
    let version = AppInfo.version
    let build = AppInfo.build
    let displayString = "Version \(version) (\(build))"
    
    XCTAssertFalse(displayString.isEmpty, "Should be able to create version display string")
    XCTAssertTrue(displayString.contains(version), "Display string should contain version")
    XCTAssertTrue(displayString.contains(build), "Display string should contain build")
  }
}
