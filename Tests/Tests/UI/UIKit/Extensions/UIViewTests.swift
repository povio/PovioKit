//
//  UIViewTests.swift
//  PovioKit_Tests
//
//  Created by Borut Tomazin on 19/09/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
import PovioKitCore

class UIViewTests: XCTestCase {
  private let shadowPath: UIBezierPath = .init(rect: .init(x: 0, y: 0, width: 100, height: 100))
  private let shadowColor: UIColor = .red
  private let shadowRadius: CGFloat = 50
  private let shadowOpacity: Float = 0.5
  private let shadowOffset: CGSize = .init(width: 5, height: 10)
  
  func test_dropShadows_allParameters() {
    let view = UIView()
    view.layer.shadowColor = UIColor.blue.cgColor
    XCTAssertNil(view.layer.shadowPath)
    XCTAssertEqual(view.layer.shadowColor, UIColor.blue.cgColor)
    XCTAssertEqual(view.layer.shadowOffset, .init(width: 0, height: -3))
    XCTAssertEqual(view.layer.shadowOpacity, 0)
    XCTAssertEqual(view.layer.shadowRadius, 3)
    
    view.dropShadow(path: shadowPath, shadowColor: shadowColor, radius: shadowRadius, opacity: shadowOpacity, offset: shadowOffset)
    XCTAssertEqual(view.layer.shadowPath, shadowPath.cgPath)
    XCTAssertEqual(view.layer.shadowColor, shadowColor.cgColor)
    XCTAssertEqual(view.layer.shadowOffset, shadowOffset)
    XCTAssertEqual(view.layer.shadowOpacity, shadowOpacity)
    XCTAssertEqual(view.layer.shadowRadius, shadowRadius)
  }
  
  func test_dropShadows_missingPath() {
    let view = UIView()
    XCTAssertNil(view.layer.shadowPath)
    
    view.dropShadow(path: nil, shadowColor: shadowColor, radius: shadowRadius, opacity: shadowOpacity, offset: shadowOffset)
    XCTAssertNil(view.layer.shadowPath)
  }
  
  func test_applyBorder() {
    let color: UIColor = .blue
    let width: CGFloat = 10
    
    let view = UIView()
    view.layer.borderColor = UIColor.black.cgColor
    XCTAssertEqual(view.layer.borderColor, UIColor.black.cgColor)
    XCTAssertEqual(view.layer.borderWidth, 0)
    
    view.applyBorder(color: color, width: width)
    XCTAssertEqual(view.layer.borderColor, color.cgColor)
    XCTAssertEqual(view.layer.borderWidth, width)
  }
  
  func test_setHidden_true() {
    let view = UIView()
    
    XCTAssertFalse(view.isHidden)
    XCTAssertEqual(view.alpha, 1)
    
    let promise = expectation(description: "Wait for animation...")
    view.setHidden(true, animationDuration: 0.01) {
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
    
    XCTAssertTrue(view.isHidden)
    XCTAssertEqual(view.alpha, 0)
  }
  
  func test_setHidden_false() {
    let view = UIView()
    view.isHidden = true
    view.alpha = 0
    
    let promise = expectation(description: "Wait for animation...")
    view.setHidden(false, animationDuration: 0.01) {
      promise.fulfill()
    }
    
    waitForExpectations(timeout: 0.1)
    
    XCTAssertFalse(view.isHidden)
    XCTAssertEqual(view.alpha, 1)
  }
  
  func test_rotate_clockwise() {
    let view = UIView()
    let expectedStartAngle = 0
    let expectedEndAngle = (Float.pi * 2.0) * 1
    
    view.rotate(speed: 1, clockwise: true)
    let animation = view.layer.animation(forKey: UIView.AnimationKey.rotation) as? CABasicAnimation
    XCTAssertNotNil(animation)
    XCTAssertEqual(animation?.fromValue as? Int, expectedStartAngle)
    XCTAssertEqual(animation?.toValue as? Float, expectedEndAngle)
    XCTAssertEqual(animation?.duration, 1)
    XCTAssertEqual(animation?.repeatCount, Float.infinity)
  }
  
  func test_rotate_anticlockwise() {
    let view = UIView()
    let expectedStartAngle = 0
    let expectedEndAngle = (Float.pi * 2.0) * -1
    
    view.rotate(speed: 1, clockwise: false)
    let animation = view.layer.animation(forKey: UIView.AnimationKey.rotation) as? CABasicAnimation
    XCTAssertNotNil(animation)
    XCTAssertEqual(animation?.fromValue as? Int, expectedStartAngle)
    XCTAssertEqual(animation?.toValue as? Float, expectedEndAngle)
    XCTAssertEqual(animation?.duration, 1)
    XCTAssertEqual(animation?.repeatCount, Float.infinity)
  }
  
  func test_rotate_doNotAddWhenExists() {
    let view = UIView()
    view.rotate(speed: 1, clockwise: true)
    XCTAssertEqual(view.layer.animationKeys()?.count, 1)
    
    view.rotate(speed: 1, clockwise: true)
    XCTAssertEqual(view.layer.animationKeys()?.count, 1)
  }
  
  func test_stopRotating() {
    let view = UIView()
    view.rotate(speed: 1, clockwise: true)
    XCTAssertEqual(view.layer.animationKeys()?.count, 1)
    
    view.stopRotating()
    XCTAssertNil(view.layer.animationKeys())
  }
}

#endif
