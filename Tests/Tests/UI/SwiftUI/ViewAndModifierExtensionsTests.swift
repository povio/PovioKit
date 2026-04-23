//
//  ViewAndModifierExtensionsTests.swift
//  PovioKit_Tests
//  Copyright © 2026 Povio Inc. All rights reserved.
//

import XCTest
import SwiftUI
import PovioKitSwiftUI

// SwiftUI's `View` builders are all `@MainActor`-isolated under
// Swift 6, so the test methods must be main-actor too in order to
// call them. XCTest dispatches `XCTestCase` methods on the main
// queue, so this isolation is free at runtime.
@MainActor
final class ViewAndModifierExtensionsTests: XCTestCase {
  func testAnyTransitionSlideLeftIsAvailable() {
    let transition = AnyTransition.slideLeft
    XCTAssertNotNil(transition)
  }
  
  func testTextLinkInitializer() {
    let text = Text("Povio", link: "https://povio.com")
    XCTAssertNotNil(text)
  }
  
  func testViewFrameHiddenAndNoAnimationHelpers() {
    let baseView = Text("Hello")
    
    let squaredFrame = baseView.frame(size: 44)
    let sizedFrame = baseView.frame(size: CGSize(width: 44, height: 20))
    let hidden = baseView.hidden(true)
    let noAnimation = baseView.noAnimation()
    
    XCTAssertNotNil(squaredFrame)
    XCTAssertNotNil(sizedFrame)
    XCTAssertNotNil(hidden)
    XCTAssertNotNil(noAnimation)
  }
  
  func testSwiftUIModifierHelpersAreAvailable() {
    let text = Text("Hello")
    let binding = Binding<String>(get: { "hello" }, set: { _ in })
    
    let onFirstAppear = text.onFirstAppear {}
    let squared = text.squared(cornerRadius: 8, aspectRatio: 1)
    let limited = TextField("Label", text: binding).limitInput(text: binding, limit: 3)
    let measured = text.measureSize { _ in }
    let measuredInitial = text.measureInitialSize { _ in }
    
    XCTAssertNotNil(onFirstAppear)
    XCTAssertNotNil(squared)
    XCTAssertNotNil(limited)
    XCTAssertNotNil(measured)
    XCTAssertNotNil(measuredInitial)
  }
  
  #if os(macOS)
  func testBlurBackgroundModifierOnMacOS() {
    let view = Text("blur").blurBackground()
    XCTAssertNotNil(view)
  }
  #endif
}
