//
//  BuilderCompatibleTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUtilities

/// Verifies the `BuilderCompatible` bridges for UIKit text-carrying views.
/// `AttributedStringBuilderTests` covers the builder itself; these tests
/// specifically exercise the `UILabel` / `UITextField` extension hooks so the
/// `.bd.apply { ... }` entry point stays green.
@MainActor
final class BuilderCompatibleTests: XCTestCase {
  func test_UILabel_bdApply_usesLabelTextAndSetsAttributedText() {
    let label = UILabel()
    label.text = "Hello"
    
    label.bd.apply {
      $0.setTextColor(.red)
      $0.setFont(.systemFont(ofSize: 20))
    }
    
    let attributed = label.attributedText
    XCTAssertEqual(attributed?.string, "Hello")
    
    let attrs = attributed?.attributes(at: 0, effectiveRange: nil)
    XCTAssertEqual(attrs?[.foregroundColor] as? UIColor, .red)
    XCTAssertEqual(attrs?[.font] as? UIFont, .systemFont(ofSize: 20))
  }
  
  func test_UILabel_bdApplyOnExplicitText_overridesLabelText() {
    let label = UILabel()
    label.text = "original"
    
    label.bd.apply(on: "override") {
      $0.setTextColor(.blue)
    }
    
    XCTAssertEqual(label.attributedText?.string, "override")
  }
  
  func test_UITextField_bdApply_usesFieldTextAndSetsAttributedText() {
    let field = UITextField()
    field.text = "World"
    
    field.bd.apply {
      $0.setTextColor(.green)
    }
    
    XCTAssertEqual(field.attributedText?.string, "World")
    let color = field.attributedText?
      .attributes(at: 0, effectiveRange: nil)[.foregroundColor] as? UIColor
    XCTAssertEqual(color, .green)
  }
  
  func test_UITextField_bdApplyOnExplicitText_overridesFieldText() {
    let field = UITextField()
    field.text = "first"
    
    field.bd.apply(on: "second") {
      $0.setFont(.boldSystemFont(ofSize: 12))
    }
    
    XCTAssertEqual(field.attributedText?.string, "second")
  }
}

#endif
