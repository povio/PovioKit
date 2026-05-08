//
//  PaddingLabelTests.swift
//  PovioKit_Tests
//
//  Copyright © 2026 Povio Inc. All rights reserved.
//

#if os(iOS)

import XCTest
import UIKit
@testable import PovioKitUIKit

@MainActor
final class PaddingLabelTests: XCTestCase {
  func test_defaultContentInset_isFivePointsOnEachEdge() {
    let label = PaddingLabel()
    XCTAssertEqual(label.contentInset, .init(top: 5, left: 5, bottom: 5, right: 5))
  }
  
  func test_intrinsicContentSize_addsHorizontalAndVerticalInsets() {
    let insets = UIEdgeInsets(top: 4, left: 8, bottom: 2, right: 6)
    let label = makeLabel(text: "Hello", contentInset: insets)
    let reference = makeLabel(text: "Hello", contentInset: .zero)
    
    XCTAssertEqual(
      label.intrinsicContentSize.width,
      reference.intrinsicContentSize.width + insets.left + insets.right,
      accuracy: 0.01
    )
    XCTAssertEqual(
      label.intrinsicContentSize.height,
      reference.intrinsicContentSize.height + insets.top + insets.bottom,
      accuracy: 0.01
    )
  }
  
  func test_changingContentInset_invalidatesIntrinsicContentSize() {
    let label = makeLabel(text: "Hi", contentInset: .zero)
    let before = label.intrinsicContentSize
    
    label.contentInset = .init(top: 20, left: 20, bottom: 20, right: 20)
    let after = label.intrinsicContentSize
    
    XCTAssertEqual(after.width - before.width, 40, accuracy: 0.01)
    XCTAssertEqual(after.height - before.height, 40, accuracy: 0.01)
  }
  
  func test_textRectForBounds_insetsBoundsByContentInset() {
    let label = makeLabel(text: "Hello, world", contentInset: .init(top: 5, left: 10, bottom: 5, right: 10))
    
    let outer = CGRect(x: 0, y: 0, width: 200, height: 100)
    let rect = label.textRect(forBounds: outer, limitedToNumberOfLines: 0)
    
    // The returned rect is measured inside the inset bounds, so it can never be
    // wider / taller than `outer` reduced by the horizontal / vertical insets.
    XCTAssertLessThanOrEqual(rect.width, outer.width - 20)
    XCTAssertLessThanOrEqual(rect.height, outer.height - 10)
  }
}

private extension PaddingLabelTests {
  func makeLabel(text: String, contentInset: UIEdgeInsets) -> PaddingLabel {
    let label = PaddingLabel()
    label.font = .systemFont(ofSize: 16)
    label.text = text
    label.contentInset = contentInset
    return label
  }
}

#endif
