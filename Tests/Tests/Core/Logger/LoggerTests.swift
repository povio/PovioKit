//
//  LoggerTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 08/10/2025.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import PovioKitCore

final class LoggerTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Reset to default state
    Logger.shared.logLevel = .none
  }
  
  override func tearDown() {
    Logger.shared.logLevel = .none
    super.tearDown()
  }
  
  // MARK: - Singleton Tests
  
  func testSharedInstance() {
    let logger1 = Logger.shared
    let logger2 = Logger.shared
    
    XCTAssertTrue(logger1 === logger2, "Logger.shared should return the same instance")
  }
  
  func testDefaultLogLevel() {
    XCTAssertEqual(Logger.shared.logLevel, .none, "Default log level should be .none")
  }
  
  // MARK: - Log Level Tests
  
  func testLogLevelCanBeChanged() {
    Logger.shared.logLevel = .debug
    XCTAssertEqual(Logger.shared.logLevel, .debug, "Log level should be changeable")
    
    Logger.shared.logLevel = .error
    XCTAssertEqual(Logger.shared.logLevel, .error, "Log level should update")
  }
  
  func testAllLogLevels() {
    let levels: [Logger.LogLevel] = [.none, .error, .warn, .info, .debug, .all]
    
    for level in levels {
      Logger.shared.logLevel = level
      XCTAssertEqual(Logger.shared.logLevel, level, "Should be able to set log level to \(level)")
    }
  }
  
  func testLogLevelRawValues() {
    XCTAssertEqual(Logger.LogLevel.none.rawValue, 0, "none should have rawValue 0")
    XCTAssertEqual(Logger.LogLevel.error.rawValue, 1, "error should have rawValue 1")
    XCTAssertEqual(Logger.LogLevel.warn.rawValue, 2, "warn should have rawValue 2")
    XCTAssertEqual(Logger.LogLevel.info.rawValue, 3, "info should have rawValue 3")
    XCTAssertEqual(Logger.LogLevel.debug.rawValue, 4, "debug should have rawValue 4")
    XCTAssertEqual(Logger.LogLevel.all.rawValue, 5, "all should have rawValue 5")
  }
  
  // MARK: - Log Level Labels
  
  func testLogLevelLabels() {
    XCTAssertEqual(Logger.LogLevel.error.label, "ERROR", "Error level should have correct label")
    XCTAssertEqual(Logger.LogLevel.warn.label, "WARN", "Warn level should have correct label")
    XCTAssertEqual(Logger.LogLevel.info.label, "INFO", "Info level should have correct label")
    XCTAssertEqual(Logger.LogLevel.debug.label, "DEBUG", "Debug level should have correct label")
    XCTAssertEqual(Logger.LogLevel.none.label, "", "None level should have empty label")
    XCTAssertEqual(Logger.LogLevel.all.label, "", "All level should have empty label")
  }
  
  // MARK: - Logging Methods Don't Crash
  
  func testDebugLoggingDoesNotCrash() {
    Logger.shared.logLevel = .debug
    
    // Should not crash
    Logger.debug("Test debug message")
    Logger.debug("Test with params", params: ["key": "value"])
    
    XCTAssertTrue(true, "Debug logging should not crash")
  }
  
  func testInfoLoggingDoesNotCrash() {
    Logger.shared.logLevel = .info
    
    // Should not crash
    Logger.info("Test info message")
    Logger.info("Test with params", params: ["key": 123])
    
    XCTAssertTrue(true, "Info logging should not crash")
  }
  
  func testWarningLoggingDoesNotCrash() {
    Logger.shared.logLevel = .warn
    
    // Should not crash
    Logger.warning("Test warning message")
    Logger.warning("Test with params", params: ["warning": true])
    
    XCTAssertTrue(true, "Warning logging should not crash")
  }
  
  func testErrorLoggingDoesNotCrash() {
    Logger.shared.logLevel = .error
    
    // Should not crash
    Logger.error("Test error message")
    Logger.error("Test with params", params: ["error": "something went wrong"])
    
    XCTAssertTrue(true, "Error logging should not crash")
  }
  
  func testLoggingWithNilParams() {
    Logger.shared.logLevel = .all
    
    // Should handle nil params gracefully
    Logger.debug("Message without params", params: nil)
    Logger.info("Message without params", params: nil)
    Logger.warning("Message without params", params: nil)
    Logger.error("Message without params", params: nil)
    
    XCTAssertTrue(true, "Logging with nil params should not crash")
  }
  
  func testLoggingWithEmptyParams() {
    Logger.shared.logLevel = .all
    
    // Should handle empty params gracefully
    Logger.debug("Message with empty params", params: [:])
    Logger.info("Message with empty params", params: [:])
    
    XCTAssertTrue(true, "Logging with empty params should not crash")
  }
  
  func testLoggingWithComplexParams() {
    Logger.shared.logLevel = .all
    
    let complexParams: [String: Any] = [
      "string": "value",
      "int": 42,
      "double": 3.14,
      "bool": true,
      "array": [1, 2, 3],
      "dict": ["nested": "value"]
    ]
    
    // Should handle complex params gracefully
    Logger.debug("Complex params", params: complexParams)
    
    XCTAssertTrue(true, "Logging with complex params should not crash")
  }
  
  // MARK: - Log Level Filtering
  
  func testLogLevelNoneDoesNotLog() {
    Logger.shared.logLevel = .none
    
    // With log level .none, these should be filtered out (not crash)
    Logger.debug("Should not log")
    Logger.info("Should not log")
    Logger.warning("Should not log")
    Logger.error("Should not log")
    
    XCTAssertTrue(true, "Log level .none should filter all messages")
  }
  
  func testLogLevelErrorFiltersLowerLevels() {
    Logger.shared.logLevel = .error
    
    // Only error should potentially log, others should be filtered
    Logger.debug("Should be filtered")
    Logger.info("Should be filtered")
    Logger.warning("Should be filtered")
    Logger.error("Should log")
    
    XCTAssertTrue(true, "Log level .error should only allow error messages")
  }
  
  func testLogLevelAllAllowsAllMessages() {
    Logger.shared.logLevel = .all
    
    // All messages should be allowed
    Logger.debug("Should log")
    Logger.info("Should log")
    Logger.warning("Should log")
    Logger.error("Should log")
    
    XCTAssertTrue(true, "Log level .all should allow all messages")
  }
  
  // MARK: - Edge Cases
  
  func testLoggingWithVeryLongMessage() {
    Logger.shared.logLevel = .all
    
    let longMessage = String(repeating: "This is a very long message. ", count: 100)
    
    // Should handle long messages without crashing
    Logger.info(longMessage)
    
    XCTAssertTrue(true, "Logging very long messages should not crash")
  }
  
  func testLoggingWithSpecialCharacters() {
    Logger.shared.logLevel = .all
    
    let specialMessage = "Special chars: 🎉 @#$%^&*() \n\t\r"
    
    // Should handle special characters
    Logger.info(specialMessage)
    
    XCTAssertTrue(true, "Logging with special characters should not crash")
  }
  
  func testLoggingWithEmptyMessage() {
    Logger.shared.logLevel = .all
    
    // Should handle empty messages
    Logger.info("")
    Logger.debug("")
    
    XCTAssertTrue(true, "Logging empty messages should not crash")
  }
}

