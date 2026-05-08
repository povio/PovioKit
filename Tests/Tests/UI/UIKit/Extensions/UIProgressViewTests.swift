//
//  UIProgressViewTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUIKit

@MainActor
final class UIProgressViewTests: XCTestCase {
  func test_setProgress_notAnimated_setsProgressAndCallsCompletionSynchronously() {
    let progressView = UIProgressView()
    var completionCalled = false
    
    progressView.setProgress(0.5, animated: false) {
      completionCalled = true
    }
    
    XCTAssertTrue(completionCalled)
    XCTAssertEqual(progressView.progress, 0.5, accuracy: 0.0001)
  }
  
  func test_setProgress_notAnimated_completionIsOptional() {
    let progressView = UIProgressView()
    progressView.setProgress(0.3, animated: false)
    XCTAssertEqual(progressView.progress, 0.3, accuracy: 0.0001)
  }
  
  func test_setProgress_animated_completionFiresAndProgressIsUpdated() {
    let progressView = UIProgressView()
    let completion = expectation(description: "Wait for animation completion")
    
    progressView.setProgress(0.75, animated: true, duration: 0.05) {
      completion.fulfill()
    }
    
    waitForExpectations(timeout: 1.0)
    XCTAssertEqual(progressView.progress, 0.75, accuracy: 0.0001)
  }
}

#endif
