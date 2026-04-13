//
//  UIViewControllerTests.swift
//  PovioKit_Tests
//
//  Created by Ndriqim Nagavci on 27/10/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitCore
import PovioKitUIKit

class UIViewControllerTests: XCTestCase {  
  func test_setLeftBarButton_addsLeftBarButton() {
    let viewController = UIViewController()
    let barButtonItem = viewController.setLeftBarButton(.init(content: .title(.default("test_title")), action: nil))
    
    XCTAssertEqual(viewController.navigationItem.leftBarButtonItem, barButtonItem)
    XCTAssertEqual(viewController.navigationItem.leftBarButtonItem?.title, barButtonItem.title)
  }
  
  func test_setRightBarButton_addsRightBarButton() {
    let viewController = UIViewController()
    let barButtonItem = viewController.setRightBarButton(.init(content: .icon(UIImage(systemName: "sun.min")), action: nil))
    
    XCTAssertNotNil(barButtonItem.image)
    XCTAssertEqual(viewController.navigationItem.rightBarButtonItem, barButtonItem)
    XCTAssertEqual(viewController.navigationItem.rightBarButtonItem?.image, barButtonItem.image)
  }
  
  func test_setLeftBarButtons_addsLeftBarButtons() {
    let viewController = UIViewController()
    let barButtonItems = viewController.setLeftBarButtons([
      .init(content: .title(.default("test_title")), action: #selector(testTarget)),
      .init(content: .title(.attributed(normal: NSAttributedString(string: "attributed_title"))), action: nil),
      .init(content: .title(.attributed(normal: NSAttributedString(string: "test_title"), disabled: nil)), action: #selector(testTarget)),
      .init(content: .icon(UIImage(systemName: "sun.min")), action: nil),
      .init(content: .icon(nil), action: nil)
    ])
    
    XCTAssertEqual(viewController.navigationItem.leftBarButtonItems, barButtonItems)
  }
  
  func test_setRightBarButtons_addsRightBarButtons() {
    let viewController = UIViewController()
    let barButtonItems = viewController.setRightBarButtons([
      .init(content: .title(.default("test_title")), action: nil),
      .init(content: .title(.default("test_title")), action: nil)
    ])
    
    XCTAssertEqual(viewController.navigationItem.rightBarButtonItems, barButtonItems)
  }
  
  @objc private func testTarget() { }
}
#endif
