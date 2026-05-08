//
//  NotificationCenterTests.swift
//  PovioKit_Tests
//
//  Created by Codex on 15/04/2026.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import Combine
import XCTest
import PovioKitCore

final class NotificationCenterTests: XCTestCase {
  private var cancellables: Set<AnyCancellable> = []
  
  override func tearDown() {
    cancellables.removeAll()
    super.tearDown()
  }
  
  func testDeviceDidShakeNameMapping() {
    XCTAssertEqual(
      AppNotification.deviceDidShake.name.rawValue,
      "com.poviokit.notification.deviceDidShake"
    )
  }
  
  func testNamedNotificationNameMapping() {
    let custom = AppNotification.named("com.poviokit.tests.custom")
    XCTAssertEqual(custom.name.rawValue, "com.poviokit.tests.custom")
  }
  
  func testObserveAndPost() {
    let custom = AppNotification.named("com.poviokit.tests.observeAndPost")
    let expectation = expectation(description: "Observer receives custom notification")
    
    let observer = NotificationCenter.observe(custom) { notification in
      XCTAssertEqual(notification.name.rawValue, custom.name.rawValue)
      expectation.fulfill()
    }
    
    NotificationCenter.post(custom)
    wait(for: [expectation], timeout: 1.0)
    NotificationCenter.remove(observer)
  }
  
  func testObserveMultipleNotifications() {
    let first = AppNotification.named("com.poviokit.tests.first")
    let second = AppNotification.named("com.poviokit.tests.second")
    let expectation = expectation(description: "Observe multiple notifications")
    expectation.expectedFulfillmentCount = 2
    
    let observers = NotificationCenter.observe([first, second]) { notification, _ in
      if notification.name == first.name || notification.name == second.name {
        expectation.fulfill()
      }
    }
    
    NotificationCenter.post(first)
    NotificationCenter.post(second)
    wait(for: [expectation], timeout: 1.0)
    observers.forEach(NotificationCenter.remove)
  }
  
  func testPublisherReceivesPostedNotification() {
    let custom = AppNotification.named("com.poviokit.tests.publisher")
    let expectation = expectation(description: "Publisher receives posted notification")
    
    NotificationCenter.publisher(for: custom)
      .sink { notification in
        XCTAssertEqual(notification.name.rawValue, custom.name.rawValue)
        expectation.fulfill()
      }
      .store(in: &cancellables)
    
    NotificationCenter.post(custom)
    wait(for: [expectation], timeout: 1.0)
  }
}
