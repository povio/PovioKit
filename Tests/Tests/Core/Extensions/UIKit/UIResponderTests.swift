//
//  UIResponderTests.swift
//  PovioKit_Tests
//
//  Created by Gentian Barileva on 01/06/2022.
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)
import XCTest
import PovioKitCore

// `UIResponder` / `UIViewController` construction and hierarchy methods
// are main-actor isolated in Swift 6.
@MainActor
class UIResponderTests: XCTestCase {
  func test_firstResponder_returnsCorrectType() {
    let sut = makeSUT()
    
    let firstResponder = sut.buttonsContainerView.firstResponder(ofType: type(of: sut))
    
    XCTAssertNotNil(firstResponder)
    XCTAssertEqual(sut, firstResponder)
  }
  
  func test_firstResponder_returnsNilOnNotMatchingType() {
    let sut = makeSUT()
    
    let firstResponder = sut.buttonsContainerView.firstResponder(ofType: SecondaryViewController.self)
    
    XCTAssertNil(firstResponder)
  }
}

// MARK: - Helpers
private extension UIResponderTests {
  func makeSUT() -> MainViewController {
    let sut = MainViewController()
    sut.loadView()
    
    return sut
  }
}
private class MainViewController: UIViewController {
  let contentView = ContentView()
  let buttonsContainerView = ButtonsContainerView()
  
  override func loadView() {
    view = contentView
    view.addSubview(buttonsContainerView)
  }
}

private class ContentView: UIView { }
private class ButtonsContainerView: UIView { }
private class SecondaryViewController: UIViewController { }
#endif
